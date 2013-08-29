//
//  UIImage+ASMPDF.m
//  UIImage-ASMPDF
//
//  Created by The Molloys on 8/29/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import "UIImage+ASMPDF.h"

static NSString* ASMPDFCacheTypeKey = @"com.amolloy.ASMPDFCacheType";

@implementation UIImage (ASMPDF)

+ (void)setASMPDFCacheType:(ASMPDFCaching)cacheType
{
	[[NSUserDefaults standardUserDefaults] setInteger:cacheType
											   forKey:ASMPDFCacheTypeKey];
}

+ (instancetype)imageWithPDFatURL:(NSURL*)url
				  destinationSize:(CGSize)destSize
{
	return [[self alloc] initWithPDFatURL:url destinationSize:destSize];
}

+ (instancetype)imageWithPDFatURL:(NSURL*)url
				  destinationSize:(CGSize)destSize
						 cropRect:(CGRect)cropRect
{
	return [[self alloc] initWithPDFatURL:url
						  destinationSize:destSize
								 cropRect:cropRect];
}

+ (instancetype)imageWithPDFatURL:(NSURL*)url
				  destinationSize:(CGSize)destSize
						   opaque:(BOOL)opaque
							scale:(CGFloat)scale
						 cropRect:(CGRect)cropRect
{
	return [[self alloc] initWithPDFatURL:url
						  destinationSize:destSize
								   opaque:opaque
									scale:scale
								 cropRect:cropRect];
}

- (UIImage*)initWithPDFatURL:(NSURL*)url
			 destinationSize:(CGSize)destSize
{
	return [self initWithPDFatURL:url
				  destinationSize:destSize
						   opaque:YES
							scale:[UIScreen mainScreen].scale
						 cropRect:CGRectZero];
}

- (UIImage*)initWithPDFatURL:(NSURL*)url
			 destinationSize:(CGSize)destSize
					cropRect:(CGRect)cropRect
{
	return [self initWithPDFatURL:url
				  destinationSize:destSize
						   opaque:YES
							scale:[UIScreen mainScreen].scale
						 cropRect:cropRect];
}

- (UIImage*)initWithPDFatURL:(NSURL*)url
			 destinationSize:(CGSize)destSize
					  opaque:(BOOL)opaque
					   scale:(CGFloat)scale
					cropRect:(CGRect)cropRect
{
	UIImage* cachedImage = [self cachedImageForURL:url
								   destinationSize:destSize
											opaque:opaque
											 scale:scale
										  cropRect:cropRect];
	if (cachedImage)
	{
		self = cachedImage;
	}
	else
	{
		CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
		CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);

		if (!page1)
		{
			self = nil;
		}
		else
		{
			UIGraphicsBeginImageContextWithOptions(destSize, opaque, scale);
			CGContextRef ctx = UIGraphicsGetCurrentContext();
			
			CGContextSaveGState(ctx);
			
			UIColor* backgroundColor = [UIColor clearColor];
			if (opaque)
			{
				backgroundColor = [UIColor whiteColor];
			}
			
			CGContextSetFillColorWithColor(ctx, backgroundColor.CGColor);
			
			CGRect drawRect = CGRectMake(0, 0, destSize.width, destSize.height);
			
			CGContextFillRect(ctx, drawRect);
			
			CGContextScaleCTM(ctx, 1, -1);
			CGContextTranslateCTM(ctx, 0, -CGRectGetHeight(drawRect));
			
			CGRect mediaRect = cropRect;
			
			if (CGRectIsEmpty(mediaRect))
			{
				mediaRect = CGPDFPageGetBoxRect( page1, kCGPDFCropBox );
			}
			
			CGContextScaleCTM(ctx,
							  drawRect.size.width / mediaRect.size.width,
							  drawRect.size.height / mediaRect.size.height);
			CGContextTranslateCTM(ctx, -mediaRect.origin.x, -mediaRect.origin.y);
			
			CGContextDrawPDFPage(ctx, page1);
			CGPDFDocumentRelease(pdf);
			
			CGContextRestoreGState(ctx);
			
			self = UIGraphicsGetImageFromCurrentImageContext();
			
			UIGraphicsEndImageContext();
			
			[self cacheImageForURL:url
				   destinationSize:destSize
							opaque:opaque
							 scale:scale
						  cropRect:cropRect];
		}
	}
	
	return self;
}

- (NSString*)diskCachePath
{
	static NSString* sDiskCachePath = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSURL* cacheURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
																  inDomains:NSUserDomainMask] lastObject];
		cacheURL = [cacheURL URLByAppendingPathComponent:@"ASMPDFCache"];
		
		NSString* cachePath = [cacheURL path];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath])
		{
			NSError* error = nil;
			if (![[NSFileManager defaultManager] createDirectoryAtPath:cachePath
										   withIntermediateDirectories:YES
															attributes:nil
																 error:&error])
			{
				NSLog(@"Error creating cache folder: %@", [error localizedDescription]);
				
				cachePath = nil;
			}
		}
		
		sDiskCachePath = cachePath;
	});
	
	return sDiskCachePath;
}

- (NSCache*)memoryCache
{
	static NSCache* sMemoryCache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sMemoryCache = [[NSCache alloc] init];
	});
	
	return sMemoryCache;
}

- (NSString*)cacheKeyForURL:(NSURL*)url
		   destinationSize:(CGSize)destSize
					opaque:(BOOL)opaque
					 scale:(CGFloat)scale
				  cropRect:(CGRect)cropRect
{
	NSString* fileURL = [url absoluteString];
	NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/:"];
    fileURL = [[fileURL componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@"-"];
	
	return [NSString stringWithFormat:@"%@-%@-%@-%@-%@",
			fileURL,
			NSStringFromCGSize(destSize),
			@(opaque),
			@(scale),
			NSStringFromCGRect(cropRect)];
}

- (UIImage*)cachedImageForURL:(NSURL*)url
			  destinationSize:(CGSize)destSize
					   opaque:(BOOL)opaque
						scale:(CGFloat)scale
					 cropRect:(CGRect)cropRect
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		[[NSUserDefaults standardUserDefaults] registerDefaults:@{ASMPDFCacheTypeKey: @(ASMPDFNoCache)}];
	});
	
	UIImage* cachedImage = nil;
	ASMPDFCaching cacheType = [[NSUserDefaults standardUserDefaults] integerForKey:ASMPDFCacheTypeKey];
	NSString* cacheKey = [self cacheKeyForURL:url
							  destinationSize:destSize
									   opaque:opaque
										scale:scale
									 cropRect:cropRect];
	
	if (ASMPDFMemoryCache & cacheType)
	{
		cachedImage = [[self memoryCache] objectForKey:cacheKey];
	}
	if (!cachedImage && (ASMPDFDiskCache & cacheType))
	{
		NSString* cachedImagePath = [[[self diskCachePath] stringByAppendingPathComponent:cacheKey] stringByAppendingPathExtension:@"png"];
		
		cachedImage = [UIImage imageWithContentsOfFile:cachedImagePath];
	}
	
	return cachedImage;
}

- (void)cacheImageForURL:(NSURL*)url
		 destinationSize:(CGSize)destSize
				  opaque:(BOOL)opaque
				   scale:(CGFloat)scale
				cropRect:(CGRect)cropRect
{
	ASMPDFCaching cacheType = [[NSUserDefaults standardUserDefaults] integerForKey:ASMPDFCacheTypeKey];
	NSString* cacheKey = [self cacheKeyForURL:url
							  destinationSize:destSize
									   opaque:opaque
										scale:scale
									 cropRect:cropRect];
	
	if (ASMPDFMemoryCache & cacheType)
	{
		[[self memoryCache] setObject:self
							   forKey:cacheKey];
	}
	if (ASMPDFDiskCache & cacheType)
	{
		NSString* cachedImagePath = [[self diskCachePath] stringByAppendingPathComponent:cacheKey];
		
		NSInteger intScale = scale;
		if (intScale != 1)
		{
			cachedImagePath = [cachedImagePath stringByAppendingFormat:@"@%@x", @(intScale)];
		}

		cachedImagePath = [cachedImagePath stringByAppendingPathExtension:@"png"];
		
		[UIImagePNGRepresentation(self) writeToFile:cachedImagePath atomically:YES];
	}
}

@end

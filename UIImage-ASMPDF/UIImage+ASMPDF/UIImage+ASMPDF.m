//
//  UIImage+ASMPDF.m
//  UIImage-ASMPDF
//
//  Created by The Molloys on 8/29/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import "UIImage+ASMPDF.h"

@implementation UIImage (ASMPDF)

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
	
	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
	CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);
	
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
	
	return self;
}

@end

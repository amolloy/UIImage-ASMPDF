//
//  UIImage+ASMPDF.h
//  UIImage-ASMPDF
//
//  Created by The Molloys on 8/29/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ASMPDF)


+ (instancetype)imageWithPDFatURL:(NSURL*)url
				  destinationSize:(CGSize)destSize;

+ (instancetype)imageWithPDFatURL:(NSURL*)url
				  destinationSize:(CGSize)destSize
						 cropRect:(CGRect)cropRect;

+ (instancetype)imageWithPDFatURL:(NSURL*)url
				  destinationSize:(CGSize)destSize
						   opaque:(BOOL)opaque
							scale:(CGFloat)scale
						 cropRect:(CGRect)cropRect;

- (UIImage*)initWithPDFatURL:(NSURL*)url
			 destinationSize:(CGSize)destSize;

- (UIImage*)initWithPDFatURL:(NSURL*)url
			 destinationSize:(CGSize)destSize
					cropRect:(CGRect)cropRect;

- (UIImage*)initWithPDFatURL:(NSURL*)url
			 destinationSize:(CGSize)destSize
					  opaque:(BOOL)opaque
					   scale:(CGFloat)scale
					cropRect:(CGRect)cropRect;

@end

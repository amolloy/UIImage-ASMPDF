//
//  ASMViewController.m
//  UIImage-ASMPDF
//
//  Created by The Molloys on 8/29/13.
//  Copyright (c) 2013 Andy Molloy. All rights reserved.
//

#import "ASMViewController.h"
#import "UIImage+ASMPDF.h"

@interface ASMViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ASMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSURL* pdfURL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"pdf"];

	NSMutableArray* images = [NSMutableArray arrayWithCapacity:4];
	
	for (int i = 0; i < 4; ++i)
	{
		UIImage* testImage = [UIImage imageWithPDFatURL:pdfURL
										destinationSize:CGSizeMake(300, 300)
											   cropRect:CGRectMake(i * 152, 0, 152, 152)];
		
		[images addObject:testImage];
	}
	
	self.imageView.image = [UIImage animatedImageWithImages:images duration:10];
}

@end

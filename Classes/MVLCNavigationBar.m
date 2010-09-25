//
//  MVLCNavigationBar.m
//  MobileVLC
//
//  Created by Romain Goyet on 11/08/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCNavigationBar.h"

@implementation MVLCNavigationBar
- (id)initWithCoder:(NSCoder *)aCoder {
	self = [super initWithCoder:aCoder];
	if (self != nil) {
		[self setTintColor:[UIColor colorWithRed:236.0/255.0 green:106.0/255.0 blue:28.0/255.0 alpha:0.2]];
	}

	UIImageView * dropShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MVLCNavigationBarShadow.png"]];
	dropShadowView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	[self addSubview:dropShadowView];
	dropShadowView.frame = CGRectMake(0.0f, 44.0f, self.bounds.size.width, 10.0f);
	[dropShadowView release];

	self.clipsToBounds = NO;

	return self;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
	UIImage *image = [UIImage imageNamed:@"MVLCNavigationBarBackground.png"];
//	CGContextClip(ctx);
//	CGContextTranslateCTM(ctx, 0, image.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0); // Otherwise the image is drawn upside-down
//	CGContextDrawImage(ctx, , image.CGImage);
	CGContextDrawTiledImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
}
@end

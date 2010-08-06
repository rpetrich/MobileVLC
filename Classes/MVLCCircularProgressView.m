//
//  MVLCCircularProgressView.m
//  MobileVLC
//
//  Created by Romain Goyet on 06/08/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCCircularProgressView.h"


@implementation MVLCCircularProgressView
@synthesize progress=_progress;
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		_progress = 0.0f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Let's rescale the context so that 0,0 is at the center, and that a radius of 1 is scaled to fit
	double scalingRatio = MIN(([self bounds].size.width)/2.0f, ([self bounds].size.height)/2.0f);
	CGContextScaleCTM(context, scalingRatio, scalingRatio);
	CGContextTranslateCTM(context, ([self bounds].size.width)/(2.0f*scalingRatio) , ([self bounds].size.height)/(2.0f*scalingRatio));

	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, 0.0f);
	CGContextAddArc(context, 0.0f, 0.0f, 1.0f, 2*M_PI*0.0, 2*M_PI*(0.5), false);
	CGContextMoveToPoint(context, 0.0f, 0.0f);
	CGContextClosePath(context);
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillPath(context);
}
@end

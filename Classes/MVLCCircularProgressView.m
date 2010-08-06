//
//  MVLCCircularProgressView.m
//  MobileVLC
//
//  Created by Romain Goyet on 06/08/10.
//  Copyright 2010 Applidium. All rights reserved.
//

#import "MVLCCircularProgressView.h"

@implementation MVLCCircularProgressView
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Let's rescale the context so that 0,0 is at the center, and that a circle with a radius of 1 is scaled to fit
	double scalingRatio = 1.0f/MIN(([self bounds].size.width)/2.0f, ([self bounds].size.height)/2.0f);
	CGContextScaleCTM(context, 1.0f/scalingRatio, 1.0f/scalingRatio);
	CGContextTranslateCTM(context, scalingRatio*([self bounds].size.width)/2.0f , scalingRatio*([self bounds].size.height)/2.0f);

	// You may want to change these two parameters
	CGColorRef color = [[UIColor whiteColor] CGColor];
	double lineWidth = 1.0f*scalingRatio;

	CGContextSetStrokeColorWithColor(context, color);
	CGContextSetLineWidth(context, lineWidth);
	
	CGRect outerCircleRect = CGRectMake(-1.0f+(lineWidth/2.0f), -1.0f+(lineWidth/2.0f), 2.0f-lineWidth, 2.0f-lineWidth);
	static const CGFloat transparentBlackColor[4] = { 0.0f, 0.0f, 0.0f, 0.2f };
	CGContextSetFillColor(context, transparentBlackColor);
	CGContextFillEllipseInRect(context, outerCircleRect);
	CGContextStrokeEllipseInRect(context, outerCircleRect);

	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, 0.0f);
	CGContextAddArc(context, 0.0f, 0.0f, 1.0f - 2*lineWidth, -M_PI/2.0f, -M_PI/2.0f + -2*M_PI*self.progress, true);
	CGContextMoveToPoint(context, 0.0f, 0.0f);
	CGContextClosePath(context);
	CGContextSetFillColorWithColor(context, color);
	CGContextFillPath(context);
}
@end

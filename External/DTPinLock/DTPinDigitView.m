//
//  DTPinDigitView.m
//  DTPinLockController
//
//  Created by Oliver Drobnik on 1/4/10.
//  Copyright 2010 Drobnik.com. All rights reserved.
//

#import "DTPinDigitView.h"

#define DOT_SIZE 20.0
#define LINE_HEIGHT 3.0
@implementation DTPinDigitView

@synthesize showDot;


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		self.backgroundColor = [UIColor clearColor];
        self.digitColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect 
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    [_digitColor set];
    if (showDot)
	{
		CGRect dotRect = CGRectMake((self.bounds.size.width - DOT_SIZE)/2.0-1, (self.bounds.size.height - DOT_SIZE)/2.0, DOT_SIZE, DOT_SIZE);   // 24, 18 for 4
		CGContextFillEllipseInRect(ctx, dotRect);
	}
    else
    {
        
        // show a line if no dot
        CGRect lineRect = CGRectMake((self.bounds.size.width - DOT_SIZE)/2.0-1,
                                     (self.bounds.size.height - LINE_HEIGHT)/2.0,
                                     DOT_SIZE,
                                     LINE_HEIGHT);
        CGContextFillRect(ctx, lineRect);
        
    }
}

- (void)setShowDot:(BOOL)shouldShowDot
{
	if (shouldShowDot != showDot)
	{
		showDot = shouldShowDot;
		[self setNeedsDisplay];
	}
}

@end

//
//  DTPinErrorView.m
//  DTPinLockController
//
//  Created by Ollie Levy on 05/05/2010.
//  Copyright 2010 Ollie Levy LTD. All rights reserved.
//

#import "DTPinErrorView.h"
#import <QuartzCore/QuartzCore.h>


@implementation DTPinErrorView
@synthesize message;


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setHidden:YES];
    }
	
    return self;
}

- (void)setMessage:(NSString *)newMessage
{
	if (message != newMessage) {
		message = newMessage;
		
		
		if ([message length] < 1.0) 
		{
			[self setHidden:YES];
			return;
		}
		
		CGRect rect = self.bounds;
        
        // calculate string size
        NSDictionary *messageAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
        NSAttributedString *attributedMessage = [[NSAttributedString alloc] initWithString:self.message
                                                                                attributes:messageAttributes];
        
		CGSize stringSize = [attributedMessage boundingRectWithSize:CGSizeMake(rect.size.width, rect.size.height)
                                                            options:NSStringDrawingTruncatesLastVisibleLine
                                                            context:nil].size;

		if (!backgroundLayer)
		{
            
            UIColor *redColor = [UIColor colorWithRed:222.0 / 255.0
                                                green:33.0 / 255.0
                                                 blue:49.0 / 255.0
                                                alpha:0.8];
            
			NSArray *gradientColors = [NSArray arrayWithObjects:(id)redColor.CGColor, (id)redColor.CGColor, (id)redColor.CGColor, nil];
		
			backgroundLayer = [CAGradientLayer layer];
			[backgroundLayer setColors:gradientColors];
			[backgroundLayer setCornerRadius:13.0];
			[backgroundLayer setBorderWidth:1.0 / [[UIScreen mainScreen] scale]];
			[backgroundLayer setBorderColor:[[UIColor colorWithRed:0.355 green:0.000 blue:0.044 alpha:1.000] CGColor]];
			[[self layer] addSublayer:backgroundLayer];
		}
		[backgroundLayer setFrame:CGRectMake((rect.size.width - (stringSize.width + 20.0)) / 2.0, 0.0, stringSize.width + 20.0 , stringSize.height + 8.0)];

		
		if (!messageLabel)
		{
			messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, stringSize.width + 20.0 , stringSize.height + 8.0)];
			[messageLabel setTextColor:[UIColor whiteColor]];
			[messageLabel setTextAlignment:NSTextAlignmentCenter];
			[messageLabel setFont:[UIFont systemFontOfSize:14.0]];
			[messageLabel setBackgroundColor:[UIColor clearColor]];
			[backgroundLayer addSublayer:[messageLabel layer]];
		}
		
		messageLabel.frame = CGRectMake(0.0, 0.0, stringSize.width + 20.0 , stringSize.height + 8.0);
		[messageLabel setText:message];
		
		[self setHidden:NO];	
	}
}

@end

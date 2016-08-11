//
//  DTPinErrorView.h
//  DTPinLockController
//
//  Created by Ollie Levy on 05/05/2010.
//  Copyright 2010 Ollie Levy LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DTPinErrorView : UIView
{
	
	NSString *message;
	CAGradientLayer *backgroundLayer;
	UILabel *messageLabel;
}

@property (nonatomic, retain) NSString *message;
@end

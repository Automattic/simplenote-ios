//
//  SPPopoverContainerViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 8/3/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPPopoverContainerViewController.h"

@interface SPPopoverContainerViewController ()

@property (nonatomic, strong) UIView *customView;

@end

@implementation SPPopoverContainerViewController

- (id)initWithCustomView:(UIView *)view {
    
    self = [super init];
    if (self) {
        _customView = view;
    }
    return self;
}

- (void)loadView {
    
    self.view = _customView;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.preferredContentSize = self.view.frame.size;
}

@end

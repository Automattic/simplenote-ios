//
//  SPTagPill.h
//  Simplenote
//
//  Created by Tom Witkin on 10/10/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPTagStub;

@interface SPTagPill : UIButton {
    
    id target;
    SEL deletionAction;
}


- (instancetype)initWithTagStub:(SPTagStub *)tagStub target:(id)target action:(SEL)action deletionAction:(SEL)deletionAction;

- (void)showDeletionView;
- (void)hideDeletionView;

@property (nonatomic) BOOL showingDeletionView;
@property (nonatomic, strong) SPTagStub *tagStub;


@end

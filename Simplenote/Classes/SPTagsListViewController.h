//
//  SPTagsListViewController.h
//  Simplenote
//
//  Created by Tom Witkin on 7/23/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTagListViewCell.h"
#import "SPSidebarViewController.h"
@class SPButton;
@class SPBorderedView;

@interface SPTagsListViewController : SPSidebarViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, SPTagListViewCellDelegate> {

    UIButton *allNotesButton;
    UIButton *trashButton;
    UIButton *settingsButton;
    SPBorderedView *customView;
    
    BOOL bEditing;
    BOOL bVisible;

    NSString *cellIdentifier;
    NSString *cellWithIconIdentifier;
    
    NSTimer *reloadTimer;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


@end

//
//  SPEntryListViewController.h
//  Simplenote
//
//  Created by Tom Witkin on 8/19/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTextField.h"

static CGFloat const EntryListCellHeight = 44;

@interface SPEntryListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    
    SPTextField *entryTextField;
    UIButton *entryFieldPlusButton;
    UITableView *autoCompleteTableView;

}

@property (nonatomic, strong) UITableView *primaryTableView;
@property (nonatomic, strong) UIView *entryFieldBackground;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSArray *autoCompleteDataSource;
@property (nonatomic) BOOL showEntryFieldPlusButton;

- (void)dismiss:(id)sender;

// sub-classes need to enter these methods
- (void)removeItemFromDataSourceAtIndexPath:(NSIndexPath *)indexPath;
- (void)processTextInField;
- (void)updateAutoCompleteMatchesForString:(NSString *)string;
- (void)updatedAutoCompleteMatches;
- (void)entryFieldPlusButtonTapped:(id)sender;

@end

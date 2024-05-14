//
//  SPEntryListViewController.h
//  Simplenote
//
//  Created by Tom Witkin on 8/19/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTextField.h"

@interface SPEntryListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    
    UITableView *primaryTableView;
    UIView *entryFieldBackground;
    SPTextField *entryTextField;
    UIButton *entryFieldPlusButton;
    UITableView *autoCompleteTableView;

}

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

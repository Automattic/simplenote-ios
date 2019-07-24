//
//  SPTableViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 10/13/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTableViewController.h"
#import "VSThemeManager.h"
#import "Simplenote-Swift.h"


@implementation SPTableViewController

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self applyStyle];
}

- (void)applyStyle {
    
    self.view.backgroundColor = [UIColor colorWithName:UIColorNameTableViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithName:UIColorNameTableViewSeparatorColor];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"UITableViewCell"];
        
        cell.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
        
        UIView *selectionView = [[UIView alloc] initWithFrame:cell.bounds];
        selectionView.backgroundColor = [UIColor colorWithName:UIColorNameTableViewCellBackgroundHighlightColor];
        cell.selectedBackgroundView = selectionView;
        
        cell.textLabel.textColor = [UIColor colorWithName:UIColorNameTableViewTextLabelColor];
        cell.detailTextLabel.textColor = [UIColor colorWithName:UIColorNameTableViewDetailTextLabelColor];
        
    }
    
    [self resetCellForReuse:cell];
    
    return cell;
}

- (void)resetCellForReuse:(UITableViewCell *)cell {
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
}


@end

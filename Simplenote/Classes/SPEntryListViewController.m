//
//  SPEntryListViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 8/19/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPEntryListViewController.h"
#import "Simplenote-Swift.h"
#import "SPEntryListCell.h"
#import "SPEntryListAutoCompleteCell.h"

static NSString *cellIdentifier = @"primaryCell";
static NSString *autoCompleteCellIdentifier = @"autoCompleteCell";
static CGFloat const EntryListTextFieldSidePadding = 15;
static CGFloat const EntryListCellHeight = 44;

@implementation SPEntryListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [primaryTableView reloadData];
}

- (void)setupViews {
    
    // setup views
    CGFloat yOrigin = self.view.safeAreaInsets.top;
    
    entryFieldBackground = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                    yOrigin,
                                                                    self.view.frame.size.width,
                                                                    EntryListCellHeight)];
    entryFieldBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:entryFieldBackground];
    
    entryTextField = [[SPTextField alloc] initWithFrame:CGRectMake(EntryListTextFieldSidePadding,
                                                                   0,
                                                                   entryFieldBackground.frame.size.width - 2 * EntryListTextFieldSidePadding,
                                                                   entryFieldBackground.frame.size.height)];
    entryTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    entryTextField.keyboardType = UIKeyboardTypeEmailAddress;

    entryTextField.keyboardAppearance = SPUserInterface.isDark ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
    entryTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    entryTextField.delegate = self;
    [entryFieldBackground addSubview:entryTextField];
    
    entryFieldPlusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pickerImage = [UIImage imageWithName:UIImageNameAdd];
    [entryFieldPlusButton setImage:pickerImage forState:UIControlStateNormal];
    entryFieldPlusButton.frame = CGRectMake(0, 0, pickerImage.size.width, pickerImage.size.height);
    [entryFieldPlusButton addTarget:self
                             action:@selector(entryFieldPlusButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
    entryTextField.rightView = entryFieldPlusButton;
    entryTextField.rightViewMode = UITextFieldViewModeAlways;
    
    
    primaryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yOrigin + entryTextField.frame.size.height,
                                                                     self.view.frame.size.width, self.view.frame.size.height - (yOrigin + entryTextField.frame.size.height))
                                                    style:UITableViewStyleGrouped];
    primaryTableView.rowHeight = EntryListCellHeight;
    primaryTableView.delegate = self;
    primaryTableView.dataSource = self;
    primaryTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:primaryTableView];
    
    
    [primaryTableView registerClass:[SPEntryListCell class]
             forCellReuseIdentifier:cellIdentifier];
    
    [autoCompleteTableView registerClass:[SPEntryListAutoCompleteCell class]
                  forCellReuseIdentifier:autoCompleteCellIdentifier];
    
    // autoCompleteTableView
    autoCompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                          yOrigin + entryTextField.frame.size.height,
                                                                          self.view.frame.size.width,
                                                                          self.view.frame.size.height - (yOrigin + entryTextField.frame.size.height))
                                                         style:UITableViewStylePlain];
    autoCompleteTableView.delegate = self;
    autoCompleteTableView.dataSource = self;
    autoCompleteTableView.hidden = YES;
    autoCompleteTableView.showsVerticalScrollIndicator = NO;
    autoCompleteTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:autoCompleteTableView];
    
    // set navigation bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismiss:)];
    
    [self applyDefaultStyle];
    
    // keyboard notifications
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)applyDefaultStyle {

    UIColor *backgroundColor = [UIColor simplenoteBackgroundColor];
    UIColor *tableBackgroundColor = [UIColor simplenoteTableViewBackgroundColor];
    UIColor *tableSeparatorColor = [UIColor simplenoteDividerColor];

    // self
    self.view.backgroundColor = tableBackgroundColor;
    
    // entry field
    entryFieldBackground.backgroundColor = tableBackgroundColor;
    entryTextField.backgroundColor = [UIColor clearColor];
    entryTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    entryTextField.textColor = [UIColor simplenoteTextColor];
    entryTextField.placeholdTextColor = [UIColor simplenoteTitleColor];
    
    CALayer *entryFieldBorder = [[CALayer alloc] init];
    entryFieldBorder.frame = CGRectMake(0,
                                        entryFieldBackground.bounds.size.height - 1.0 / [[UIScreen mainScreen] scale],
                                        MAX(self.view.frame.size.width, self.view.frame.size.height),
                                        1.0 / [[UIScreen mainScreen] scale]);
    entryFieldBorder.backgroundColor = tableSeparatorColor.CGColor;
    [entryFieldBackground.layer addSublayer:entryFieldBorder];
    
    // tableview
    primaryTableView.backgroundColor = [UIColor clearColor];
    primaryTableView.separatorColor = tableSeparatorColor;
    autoCompleteTableView.backgroundColor = backgroundColor;
    autoCompleteTableView.separatorColor = tableSeparatorColor;
}

- (void)dismiss:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setShowEntryFieldPlusButton:(BOOL)showEntryFieldPlusButton {
    
    _showEntryFieldPlusButton = showEntryFieldPlusButton;
    entryFieldPlusButton.hidden = !_showEntryFieldPlusButton;
}

- (void)entryFieldPlusButtonTapped:(id)sender {
    
    // implemented by a sub-class
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:primaryTableView])
        return 0; // this is implemented by subclassing
    else if ([tableView isEqual:autoCompleteTableView])
        return _autoCompleteDataSource.count;
    
    return 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *finalCell;
    
    if ([tableView isEqual:primaryTableView]) {
        
        
        SPEntryListCell *cell = (SPEntryListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[SPEntryListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:cellIdentifier];
        }
        
        finalCell = cell;
        
    } else {
        
        SPEntryListAutoCompleteCell *cell = (SPEntryListAutoCompleteCell *)[tableView dequeueReusableCellWithIdentifier:autoCompleteCellIdentifier];
        if (!cell) {
            cell = [[SPEntryListAutoCompleteCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:autoCompleteCellIdentifier];
        }
        
        finalCell = cell;;
    }
    finalCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return finalCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [tableView isEqual:primaryTableView] ? YES : NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        [self removeItemFromDataSourceAtIndexPath:indexPath];
        [primaryTableView beginUpdates];
        [primaryTableView deleteRowsAtIndexPaths:@[indexPath]
                                withRowAnimation:UITableViewRowAnimationLeft];
        [primaryTableView endUpdates];
    }
}
- (void)removeItemFromDataSourceAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.dataSource removeObjectAtIndex:indexPath.row];
}


#pragma mark UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                             withString:string];
    
    // check for matches
    [self updateAutoCompleteMatchesForString:textField.text];
    
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self processTextInField];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    // clear auto complete matches
    autoCompleteTableView.hidden = YES;
    [self updateAutoCompleteMatchesForString:nil];
}

- (void)processTextInField {
    
    // to be implemented by a subclass
}

- (void)updateAutoCompleteMatchesForString:(NSString *)string {
    
    // to be implemented by subclasses
}
- (void)updatedAutoCompleteMatches {
    
    autoCompleteTableView.hidden = !(self.autoCompleteDataSource.count > 0);
    [autoCompleteTableView reloadData];
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if ([scrollView isEqual:primaryTableView])
        [entryTextField resignFirstResponder];    
}

#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardFrame = [(NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = MIN(keyboardFrame.size.height, keyboardFrame.size.width);
    
    CGRect newAutoCompleteFame = autoCompleteTableView.frame;
    newAutoCompleteFame.size.height = self.view.frame.size.height -  newAutoCompleteFame.origin.y - keyboardHeight;
    
    UIEdgeInsets contentInset = autoCompleteTableView.contentInset;
    contentInset.bottom = keyboardHeight;
    autoCompleteTableView.contentInset = contentInset;
}



@end

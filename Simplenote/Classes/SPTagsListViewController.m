#import "SPTagsListViewController.h"
#import "VSThemeManager.h"
#import "Tag.h"
#import "SPAppDelegate.h"
#import <Simperium/Simperium.h>
#import "SPNoteListViewController.h"
#import "SPTagListViewCell.h"
#import "SPObjectManager.h"
#import "SPBorderedView.h"
#import "SPButton.h"
#import "SPOptionsViewController.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"


// MARK: - Constants
//
#define kSectionTags 0

static CGFloat const SPSettingsButtonHeight = 40;
static UIEdgeInsets SPButtonContentInsets = {0, 25, 0, 0};
static UIEdgeInsets SPButtonImageInsets = {0, -10, 0, 0};


// MARK: - Private
//
@interface SPTagsListViewController ()

@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) UITableView                   *tableView;
@property (nonatomic, strong) Tag                           *renameTag;
@property (nonatomic, strong) UIImage                       *allNotesImage;
@property (nonatomic, strong) UIImage                       *trashImage;
@property (nonatomic, strong) UIImage                       *settingsImage;

@end


// MARK: - SPTagsListViewController Implementation
//
@implementation SPTagsListViewController

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    
    if (!customView) {
        customView = [SPBorderedView new];
        customView.fillColor = [UIColor colorWithName:UIColorNameBackgroundColor];
        customView.borderColor = [UIColor colorWithName:UIColorNameDividerColor];
        customView.showLeftBorder = NO;
        customView.showBottomBorder = NO;
        customView.showTopBorder = NO;
        customView.showRightBorder = NO;
        self.view = customView;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // apply styling
    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];

    settingsButton = [self buildSettingsButton];
    [self.view addSubview:settingsButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.tableView];

    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.alwaysBounceVertical = YES;
    self.tableView.rowHeight = 36;
    self.tableView.allowsSelection = YES;
    
    // register custom cell
    cellIdentifier = self.theme.name;
    cellWithIconIdentifier = [self.theme.name stringByAppendingString:@"WithIcon"];
    [self.tableView registerClass:[SPTagListViewCell class]
           forCellReuseIdentifier:cellIdentifier];
    [self.tableView registerClass:[SPTagListViewCell class]
           forCellReuseIdentifier:cellWithIconIdentifier];
    [self.tableView setTableHeaderView:[self buildTableHeaderView]];
    
    _settingsImage = [UIImage imageWithName:UIImageNameSettings];
    _allNotesImage = [UIImage imageWithName:UIImageNameAllNotes];
    _trashImage = [UIImage imageWithName:UIImageNameTrash];

    // add rename item to manu
    SEL renameSelector = sel_registerName("rename:");
    UIMenuItem *renameItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename", @"Rename a tag")
                                                        action:renameSelector];
    [[UIMenuController sharedMenuController] setMenuItems:@[renameItem]];
    [[UIMenuController sharedMenuController] update];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(menuDidChangeVisibility:) name:UIMenuControllerDidHideMenuNotification object:nil];
    [nc addObserver:self selector:@selector(menuDidChangeVisibility:) name:UIMenuControllerDidShowMenuNotification object:nil];
    [nc addObserver:self selector:@selector(updateSortOrder:) name:SPAlphabeticalTagSortPreferenceChangedNotification object:nil];

    [nc addObserver:self selector:@selector(themeDidChange) name:VSThemeManagerThemeDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Register for keyboard notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGFloat safeBottomInset = self.view.safeAreaInsets.bottom;
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.height = self.view.frame.size.height - SPSettingsButtonHeight - safeBottomInset;
    self.tableView.frame = tableViewFrame;
    
    settingsButton.frame = CGRectMake(tableViewFrame.origin.x,
                                      tableViewFrame.size.height,
                                      tableViewFrame.size.width,
                                      SPSettingsButtonHeight);
    
    [self updateHeaderButtonHighlight];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyboardObservers];
}

- (void)removeKeyboardObservers {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver: self name:UIKeyboardWillHideNotification object:nil];
    [nc removeObserver: self name:UIKeyboardWillShowNotification object:nil];
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (void)themeDidChange {
    [self updateHeaderColors];
    customView.fillColor = [UIColor colorWithName:UIColorNameBackgroundColor];
    customView.borderColor = [UIColor colorWithName:UIColorNameDividerColor];

    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];

    cellIdentifier = self.theme.name;
    cellWithIconIdentifier = [self.theme.name stringByAppendingString:@"WithIcon"];
    [self.tableView reloadData];

    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
}

- (void)updateHeaderColors {
    UIColor *tintColor = [UIColor colorWithName:UIColorNameTintColor];
    UIColor *textColor = [UIColor colorWithName:UIColorNameTextColor];
    UIColor *separatorColor = [UIColor colorWithName:UIColorNameDividerColor];
    UIColor *tagsTextColor = [UIColor colorWithName:UIColorNameNoteBodyFontPreviewColor];

    headerSeparator.backgroundColor = separatorColor;
    footerSeparator.backgroundColor = separatorColor;
    tagsLabel.textColor = tagsTextColor;
    [allNotesButton setTitleColor:textColor forState:UIControlStateNormal];
    [allNotesButton setTitleColor:tintColor forState:UIControlStateHighlighted];

    [trashButton setTitleColor:textColor forState:UIControlStateNormal];
    [trashButton setTitleColor:tintColor forState:UIControlStateHighlighted];

    [settingsButton setTitleColor:textColor forState:UIControlStateNormal];
    [settingsButton setTitleColor:tintColor forState:UIControlStateHighlighted];
    [settingsButton setTintColor:textColor];

    [editTagsButton setTitleColor:tintColor forState:UIControlStateNormal];
}

- (void)menuDidChangeVisibility:(UIMenuController *)menuController {
    
    self.tableView.allowsSelection = ![UIMenuController sharedMenuController].menuVisible;
}


#pragma mark - Button actions

- (void)allNotesTap:(UIButton *)sender {
    [self openNoteListForTagName:nil];
}

- (void)trashTap:(UIButton *)sender {
    [SPTracker trackTrashViewed];
    [self openNoteListForTagName:kSimplenoteTagTrashKey];
}

- (void)settingsTap:(UIButton *)sender {
    [[SPAppDelegate sharedDelegate] showOptions];
}

- (void)editTagsTap:(UIButton *)sender {
    [self setEditing:!bEditing canceled:NO];
}


#pragma mark - Table view data source

- (SPTagListViewCell *)cellForTag:(Tag *)tag {
    
    return (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self rowForTag:tag]
                                                                                          inSection:kSectionTags]];
}

- (NSInteger)rowForTag:(Tag *)tag {
    
    return [self.fetchedResultsController indexPathForObject:tag].row;
}

- (Tag *)tagAtRow:(NSInteger)row {
    if (row >= self.fetchedResultsController.fetchedObjects.count) {
        return nil;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

-(NSInteger)numTags
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ((section == kSectionTags) &&
        self.fetchedResultsController.fetchedObjects.count == 0) {
        return 1;
    }
    
    return 10;
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:SPAlphabeticalTagSortPref];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == kSectionTags) {
		return [self numTags];
    }
    
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTagListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[SPTagListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    [cell resetCellForReuse];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(SPTagListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.tagNameTextField.delegate = self;
    cell.delegate = self;
    
    NSString *cellText;
    UIImage *cellIcon;
    BOOL selected = NO;

    Tag *tag = [self tagAtRow: indexPath.row];
    cellText = tag.name;
    cellIcon = nil;
    selected = bEditing ? NO : [[SPAppDelegate sharedDelegate].selectedTag isEqualToString:tag.name];
    
    if (cellText) {
        [cell setTagNameText:cellText];
    }
    [cell setIconImage:cellIcon];
    
    cell.accessibilityLabel = cellText;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.selected = selected;
    });
}

- (void)updateHeaderButtonHighlight {
    UIColor *tintColor = [UIColor colorWithName:UIColorNameTintColor];
    UIColor *textColor = [UIColor colorWithName:UIColorNameTextColor];

    if ([SPAppDelegate sharedDelegate].selectedTag == nil) {
        [allNotesButton setTitleColor:tintColor forState:UIControlStateNormal];
        [allNotesButton setTintColor:tintColor];
        [trashButton setTitleColor:textColor forState:UIControlStateNormal];
        [trashButton setTintColor:textColor];
    } else if ([[SPAppDelegate sharedDelegate].selectedTag  isEqual:@"trash"]) {
        [trashButton setTitleColor:tintColor forState:UIControlStateNormal];
        [trashButton setTintColor:tintColor];
        [allNotesButton setTitleColor:textColor forState:UIControlStateNormal];
        [allNotesButton setTintColor:textColor];
    } else {
        [trashButton setTitleColor:textColor forState:UIControlStateNormal];
        [trashButton setTintColor:textColor];
        [allNotesButton setTitleColor:textColor forState:UIControlStateNormal];
        [allNotesButton setTintColor:textColor];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL response = indexPath.section == kSectionTags;
    if (response) {
        [SPTracker trackTagCellPressed];
    }
    
    return indexPath.section == kSectionTags;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return YES;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = [self tagAtRow: indexPath.row];

    if (bEditing) {
        [SPTracker trackTagRowRenamed];
        [self renameTagAction:tag];
    } else {
        [SPTracker trackListTagViewed];
        [self openNoteListForTagName:tag.name];
    }

    [self updateHeaderButtonHighlight];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == kSectionTags && destinationIndexPath.section == kSectionTags) {
        
        [[SPObjectManager sharedManager] moveTagFromIndex:sourceIndexPath.row
                                                  toIndex:destinationIndexPath.row];
        
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != kSectionTags || proposedDestinationIndexPath.section != kSectionTags) {

        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath ? proposedDestinationIndexPath : sourceIndexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Detemine if it's in editing mode
    if (bEditing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SPTracker trackTagRowDeleted];
		[self removeTagAtIndexPath:indexPath];
    }
}


#pragma mark - UITagListViewCellDelegate

- (void)tagListViewCellShouldRenameTag:(SPTagListViewCell *)cell {
    
    [SPTracker trackTagMenuRenamed];
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    [self renameTagAction:[self tagAtRow:path.row]];
}

- (void)tagListViewCellShouldDeleteTag:(SPTagListViewCell *)cell {
    
    [SPTracker trackTagMenuDeleted];
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    [self removeTagAtIndexPath:path];
}

- (void)setEditing:(BOOL)editing canceled:(BOOL)isCanceled {
    
    if (bEditing == editing) {
        return;
    }
    
    bEditing = editing;

    self.tableView.allowsSelectionDuringEditing = YES;
    [self.tableView setEditing:editing animated:YES];
    
    if (editing) {
        [editTagsButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
		[SPTracker trackTagEditorAccessed];
    } else {
        [editTagsButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    }

    SPSidebarContainerViewController *noteListViewController = (SPSidebarContainerViewController *)[[SPAppDelegate sharedDelegate] noteListViewController];
    CGFloat newWidth = editing
        ? [self.theme floatForKey:@"containerViewSidePanelWidthExpanded"]
        : [self.theme floatForKey:@"containerViewSidePanelWidth"];
    CGRect frame = self.view.frame;
    frame.size.width = newWidth;

    CGRect notesFrame = noteListViewController.rootView.frame;
    notesFrame.origin.x = newWidth;
    if (!isCanceled) {
        // Make the tags list wider, and move the notes list over to accomodate for the new width
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.view.frame = frame;
                             noteListViewController.rootView.frame = notesFrame;
                         } completion:^(BOOL finished) {
                             nil;
                         }];
    } else {
        self.view.frame = frame;
    }
    
    return;
}

- (void)doneEditingAction:(id)sender {
    
    if (_renameTag) {
        
        SPTagListViewCell *cell = (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self rowForTag:_renameTag] inSection:kSectionTags]];
        [cell.tagNameTextField endEditing:YES];
    }
    
    [self setEditing:NO canceled:NO];
}

-(void)openNoteListForTagName:(NSString *)tag {
    
    BOOL fetchNeeded = NO;

	SPAppDelegate *appDelegate = [SPAppDelegate sharedDelegate];
    // Only perform a fetch if the view has actually changed
    if (tag != nil || appDelegate.selectedTag) {
        fetchNeeded = ![tag isEqualToString:appDelegate.selectedTag] || (tag != nil && appDelegate.selectedTag == nil) || (appDelegate.selectedTag != nil && tag == nil);
	} else if (tag == nil && appDelegate.selectedTag != nil) {
        fetchNeeded = YES;
	}
    
	appDelegate.selectedTag = tag;
    
    if (fetchNeeded) {
        [[SPAppDelegate sharedDelegate].noteListViewController update];
    }
	
    [[self containerViewController] hideSidePanelAnimated:YES completion:nil];
}

#pragma mark - UIGestureDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}



#pragma mark - Tag Actions

- (void)removeTagAtIndexPath:(NSIndexPath *)indexPath {
    
    Tag *tag = [self tagAtRow:indexPath.row];
    if (!tag) {
        return;
    }
    
    // see if this is the current tag
	SPAppDelegate *appDelegate = [SPAppDelegate sharedDelegate];
    if ([appDelegate.selectedTag isEqual:tag.name]) {
        appDelegate.selectedTag = nil;
        [appDelegate.noteListViewController update];
    }
    
    BOOL lastTag = [self numTags] == 1;

    if ([[SPObjectManager sharedManager] removeTag:tag] && !lastTag) {
        
        [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    } else
        [self.tableView reloadData];
}

- (void)renameTagAction:(Tag *)tag {
    
    if (_renameTag) {
        
        SPTagListViewCell *cell = (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self rowForTag:_renameTag]
                                                                                                                 inSection:kSectionTags]];
        [cell.tagNameTextField endEditing:YES];
    }
    
    _renameTag = tag;
    
    // begin editing the text field
    SPTagListViewCell *cell = [self cellForTag:tag];
    
    [cell setTextFieldEditable:YES];
    [cell.tagNameTextField becomeFirstResponder];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL endEditing = NO;
    if ([string hasPrefix:@" "]) {
        string = nil;
        endEditing = YES;
    } else if ([string rangeOfString:@" "].location != NSNotFound) {
        
        string = [string substringWithRange:NSMakeRange(0, [string rangeOfString:@" "].location)];
        endEditing = YES;
    }
    
    if (string)
        [textField setText:[textField.text stringByReplacingCharactersInRange:range
                                                              withString:string]];
    
    if (endEditing)
        [textField endEditing:YES];
    
    return NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    SPTagListViewCell *cell = (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self rowForTag:_renameTag]
                                                                                                             inSection:kSectionTags]];
    // deselect cell if editing
    if (bEditing) {
        [cell setSelected:NO animated:YES];
    }
    
    
    // see if tag already exists, if not rename. If it does, revert back to original name
    BOOL renameTag = ![[SPObjectManager sharedManager] tagExists:textField.text];
    
    if (renameTag) {
        
        NSString *orignalTagName = _renameTag.name;
        NSString *newTagName = textField.text;
        [[SPObjectManager sharedManager] editTag:_renameTag title:newTagName];
        
        // see if this is the current tag
		SPAppDelegate *appDelegate = [SPAppDelegate sharedDelegate];
        if ([appDelegate.selectedTag isEqual:orignalTagName]) {
            appDelegate.selectedTag = newTagName;
            [appDelegate.noteListViewController update];
        }
    }
    else
        textField.text = _renameTag.name;
    
    _renameTag = nil;
    
    [cell setTagNameText:textField.text];
    [cell setTextFieldEditable:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - SidePanelDelegate

- (void)containerViewControllerDidHideSidePanel:(SPSidebarContainerViewController *)container {
    
    bVisible = NO;
    [self setEditing:NO canceled:YES];
    
}
- (void)containerViewControllerDidShowSidePanel:(SPSidebarContainerViewController *)container {
    
    bVisible = YES;
}

- (BOOL)containerViewControllerShouldShowSidePanel:(SPSidebarContainerViewController *)container {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self->bVisible)
            [self.tableView reloadData];
    });
    
    return YES;
}

- (void)containerViewController:(SPSidebarContainerViewController *)container didChangeContentInset:(UIEdgeInsets)contentInset {

    contentInset.bottom = self.tableView.contentInset.bottom;
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
    self.tableView.contentOffset = CGPointMake(0, -contentInset.top);
}


#pragma mark - Fetched results controller

- (NSArray *)sortDescriptors
{
    BOOL isAlphaSort = [[NSUserDefaults standardUserDefaults] boolForKey:SPAlphabeticalTagSortPref];
    NSSortDescriptor *sortDescriptor;
    if (isAlphaSort) {
        sortDescriptor = [[NSSortDescriptor alloc]
                          initWithKey:@"name"
                          ascending:YES
                          selector:@selector(localizedCaseInsensitiveCompare:)];
    } else {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    }

    NSArray *sortDescriptors = @[sortDescriptor];
    return sortDescriptors;
}

- (void)performFetch {
    
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}
    
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];

    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = entity;
    [fetchRequest setFetchBatchSize:20];
    fetchRequest.sortDescriptors = [self sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:context
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [self performFetch];
    
    return _fetchedResultsController;
}


#pragma mark - Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (!bVisible) {
        return;
    }
    
    [reloadTimer invalidate];
    reloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                   target:self
                                                 selector:@selector(delayedReloadData)
                                                 userInfo:nil
                                                  repeats:NO];
}

- (void)delayedReloadData {
    
    [self.tableView reloadData];
    
    [reloadTimer invalidate];
    reloadTimer = nil;
}


#pragma mark - KeyboardNotifications

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [(NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = MIN(keyboardFrame.size.height, keyboardFrame.size.width);
    
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height = newFrame.size.height - keyboardHeight + SPSettingsButtonHeight;
    
    CGFloat animationDuration = [(NSNumber *)[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.tableView.frame = newFrame;
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height = self.view.superview.frame.size.height - self.view.frame.origin.y - SPSettingsButtonHeight;

    CGFloat animationDuration = [(NSNumber *)[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.tableView.frame = newFrame;
                     }];
    
}


#pragma mark - Interface Setup

- (CGFloat)thinLineSize {
    return 1.0 / [[UIScreen mainScreen] scale];
}

- (UIButton *)buildSettingsButton {
    settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [settingsButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [settingsButton setImage:[UIImage imageWithName:UIImageNameSettings] forState:UIControlStateNormal];
    [settingsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [settingsButton setContentEdgeInsets:SPButtonContentInsets];
    [settingsButton setImageEdgeInsets:SPButtonImageInsets];
    [settingsButton setTitle:NSLocalizedString(@"Settings", nil) forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(settingsTap:) forControlEvents:UIControlEventTouchUpInside];

    footerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, settingsButton.frame.size.width, self.thinLineSize)];
    footerSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [settingsButton addSubview:footerSeparator];

    return settingsButton;
}

- (UIView *)buildTableHeaderView {
    CGRect headerFrame = CGRectMake(0, 0, 0, 121);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];

    allNotesButton = [self buildHeaderButton];
    allNotesButton.frame = CGRectMake(0, 10, headerView.frame.size.width, 32);
    [allNotesButton setImage:[[UIImage imageWithName:UIImageNameAllNotes] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [allNotesButton setTitle:NSLocalizedString(@"All Notes", nil) forState:UIControlStateNormal];
    [allNotesButton addTarget:self action:@selector(allNotesTap:) forControlEvents:UIControlEventTouchUpInside];

    [headerView addSubview:allNotesButton];

    trashButton = [self buildHeaderButton];
    trashButton.frame = CGRectMake(0, 42, headerView.frame.size.width, 32);
    [trashButton setImage:[[UIImage imageWithName:UIImageNameTrash] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [trashButton setTitle:NSLocalizedString(@"Trash-noun", nil) forState:UIControlStateNormal];
    [trashButton addTarget:self action:@selector(trashTap:) forControlEvents:UIControlEventTouchUpInside];

    [headerView addSubview:trashButton];

    headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 84 - self.thinLineSize, 0, self.thinLineSize)];
    headerSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerSeparator.backgroundColor = [UIColor colorWithName:UIColorNameDividerColor];
    [headerView addSubview:headerSeparator];

    UIView *tagsView = [[UIView alloc] initWithFrame:CGRectMake(0, 101, 0, 20)];
    tagsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 0, 20)];
    [tagsLabel setFont: [UIFont systemFontOfSize: 14]];
    tagsLabel.text = [NSLocalizedString(@"Tags", nil) uppercaseString];
    tagsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [tagsView addSubview:tagsLabel];

    editTagsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    editTagsButton.frame = CGRectMake(0, 0, 0, 20);
    editTagsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    editTagsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [editTagsButton.titleLabel setFont: [UIFont systemFontOfSize: 14]];
    editTagsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    [editTagsButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    [editTagsButton addTarget:self action:@selector(editTagsTap:) forControlEvents:UIControlEventTouchUpInside];
    [tagsView addSubview:editTagsButton];

    [self updateHeaderColors];

    [headerView addSubview:tagsView];
    
    return headerView;
}

- (UIButton *)buildHeaderButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setContentEdgeInsets:SPButtonContentInsets];
    [button setImageEdgeInsets:SPButtonImageInsets];
    [button.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];

    return button;
}

- (void)updateSortOrder:(id)sender {
    [[self.fetchedResultsController fetchRequest] setSortDescriptors:[self sortDescriptors]];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.tableView reloadData];
}

@end

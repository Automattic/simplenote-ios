#import "SPTagsListViewController.h"
#import "SPAppDelegate.h"
#import "SPNoteListViewController.h"
#import "SPTagListViewCell.h"
#import "SPObjectManager.h"
#import "SPBorderedView.h"
#import "SPButton.h"
#import "SPOptionsViewController.h"
#import "SPTracker.h"
#import "SPTagListViewCell.h"
#import "Tag.h"

#import "VSThemeManager.h"
#import <Simperium/Simperium.h>
#import "Simplenote-Swift.h"


// MARK: - Constants
//
typedef NS_ENUM(NSInteger, SPTagsListSection) {
    SPTagsListSectionSystem = 0,
    SPTagsListSectionTags   = 1,
    SPTagsListSectionCount  = 2
};

typedef NS_ENUM(NSInteger, SPTagsListSystemRow) {
    SPTagsListSystemRowAllNotes = 0,
    SPTagsListSystemRowTrash    = 1,
    SPTagsListSystemRowSettings = 2,
    SPTagsListSystemRowCount    = 3
};


// MARK: - Private
//
@interface SPTagsListViewController () <NSFetchedResultsControllerDelegate,
                                        SPTagListViewCellDelegate,
                                        UIGestureRecognizerDelegate,
                                        UITextFieldDelegate,
                                        UITableViewDelegate,
                                        UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView          *tableView;
@property (nonatomic, strong) UIButton                      *editTagsButton;
@property (nonatomic, strong) UILabel                       *tagsLabel;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) Tag                           *renameTag;
@property (nonatomic, strong) NSString                      *cellIdentifier;
@property (nonatomic, strong) NSTimer                       *reloadTimer;
@property (nonatomic, assign) BOOL                          bEditing;
@property (nonatomic, assign) BOOL                          bVisible;

@end


// MARK: - SPTagsListViewController Implementation
//
@implementation SPTagsListViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
    [self configureTableView];
    [self configureMenuController];
    [self startListeningToNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startListeningToKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopListeningToKeyboardNotifications];
}

- (void)configureView {
    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
}

- (void)configureTableView {
    self.cellIdentifier = self.theme.name;
    self.tableView.rowHeight = 36;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.tableView registerClass:[SPTagListViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    [self.tableView setTableHeaderView:[self buildTableHeaderView]];
}

- (void)configureMenuController {
    SEL renameSelector = sel_registerName("rename:");
    UIMenuItem *renameItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename", @"Rename a tag")
                                                        action:renameSelector];
    [[UIMenuController sharedMenuController] setMenuItems:@[renameItem]];
    [[UIMenuController sharedMenuController] update];
}

- (void)startListeningToNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(menuDidChangeVisibility:) name:UIMenuControllerDidHideMenuNotification object:nil];
    [nc addObserver:self selector:@selector(menuDidChangeVisibility:) name:UIMenuControllerDidShowMenuNotification object:nil];
    [nc addObserver:self selector:@selector(updateSortOrder:) name:SPAlphabeticalTagSortPreferenceChangedNotification object:nil];
    [nc addObserver:self selector:@selector(themeDidChange) name:VSThemeManagerThemeDidChangeNotification object:nil];
    [nc addObserver:self selector:@selector(stopListeningToKeyboardNotifications) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)startListeningToKeyboardNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)stopListeningToKeyboardNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver: self name:UIKeyboardWillHideNotification object:nil];
    [nc removeObserver: self name:UIKeyboardWillShowNotification object:nil];
}

- (VSTheme *)theme {
    return [[VSThemeManager sharedManager] theme];
}

- (void)themeDidChange {
    [self updateHeaderColors];

    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];

    self.cellIdentifier = self.theme.name;
    [self.tableView reloadData];

    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
}

- (void)updateHeaderColors {
    UIColor *tintColor = [UIColor colorWithName:UIColorNameTintColor];
    UIColor *tagsTextColor = [UIColor colorWithName:UIColorNameNoteBodyFontPreviewColor];

    self.tagsLabel.textColor = tagsTextColor;
    [self.editTagsButton setTitleColor:tintColor forState:UIControlStateNormal];
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
    [self setEditing:!self.bEditing canceled:NO];
}


#pragma mark - UITableViewDataSource

- (SPTagListViewCell *)cellForTag:(Tag *)tag {
    NSIndexPath *indexPath = [self indexPathForTag:tag];
    return (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForTag:(Tag *)tag {
    NSInteger row = [self.fetchedResultsController indexPathForObject:tag].row;
    return [NSIndexPath indexPathForItem:row inSection:SPTagsListSectionTags];
}

- (Tag *)tagAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.fetchedResultsController.fetchedObjects.count || indexPath.section != SPTagsListSectionTags) {
        return nil;
    }

    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSInteger)numberOfTags {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return sectionInfo.numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ((section == SPTagsListSectionTags) &&
        self.fetchedResultsController.fetchedObjects.count == 0) {
        return 1;
    }
    
    return 10;
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:SPAlphabeticalTagSortPref];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SPTagsListSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case SPTagsListSectionSystem: {
            return SPTagsListSystemRowCount;
        }
        case SPTagsListSectionTags: {
            return self.numberOfTags;
        }
        default: {
            NSAssert(false, @"Unsupported section");
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPTagListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    if (!cell) {
        cell = [[SPTagListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }

    [cell resetCellForReuse];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(SPTagListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SPTagsListSectionSystem: {
            [self configureSystemCell:cell atIndexPath:indexPath];
            break;
        }
        case SPTagsListSectionTags: {
            [self configureTagCell:cell atIndexPath:indexPath];
            break;
        }
    }
}

- (void)configureSystemCell:(SPTagListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case SPTagsListSystemRowAllNotes: {
            cell.textLabel.text = NSLocalizedString(@"All Notes", nil);
            cell.imageView.image = [UIImage imageWithName:UIImageNameAllNotes];
            break;
        }
        case SPTagsListSystemRowTrash: {
            cell.textLabel.text = NSLocalizedString(@"Trash-noun", nil);
            cell.imageView.image = [UIImage imageWithName:UIImageNameTrash];
            break;
        }
        case SPTagsListSystemRowSettings: {
            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
            cell.imageView.image = [UIImage imageWithName:UIImageNameSettings];
            break;
        }
    }

//    static UIEdgeInsets SPButtonContentInsets = {0, 25, 0, 0};
//    static UIEdgeInsets SPButtonImageInsets = {0, -10, 0, 0};

//    [button setContentEdgeInsets:SPButtonContentInsets];
//    [button setImageEdgeInsets:SPButtonImageInsets];
//    [button.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];

//    [allNotesButton addTarget:self action:@selector(allNotesTap:) forControlEvents:UIControlEventTouchUpInside];
//    [trashButton addTarget:self action:@selector(trashTap:) forControlEvents:UIControlEventTouchUpInside];

//    [settingsButton setImage:[UIImage imageWithName:UIImageNameSettings] forState:UIControlStateNormal];
//    [settingsButton setContentEdgeInsets:SPButtonContentInsets];
//    [settingsButton setImageEdgeInsets:SPButtonImageInsets];
//    [settingsButton.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
}

- (void)configureTagCell:(SPTagListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.tagNameTextField.delegate = self;
    cell.delegate = self;

    Tag *tag = [self tagAtIndexPath:indexPath];
    NSString *cellText = tag.name;
    UIImage *cellIcon = [UIImage imageWithName:UIImageNameTag];
    BOOL selected = self.bEditing ? NO : [[SPAppDelegate sharedDelegate].selectedTag isEqualToString:tag.name];
    
    if (cellText) {
        [cell setTagNameText:cellText];
    }
    [cell setIconImage:cellIcon];
    
    cell.accessibilityLabel = cellText;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.selected = selected;
    });
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL response = indexPath.section == SPTagsListSectionTags;
    if (response) {
        [SPTracker trackTagCellPressed];
    }
    
    return response;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return YES;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = [self tagAtIndexPath:indexPath];

    if (self.bEditing) {
        [SPTracker trackTagRowRenamed];
        [self renameTagAction:tag];
    } else {
        [SPTracker trackListTagViewed];
        [self openNoteListForTagName:tag.name];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == SPTagsListSectionTags && destinationIndexPath.section == SPTagsListSectionTags) {
        
        [[SPObjectManager sharedManager] moveTagFromIndex:sourceIndexPath.row
                                                  toIndex:destinationIndexPath.row];
        
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (sourceIndexPath.section != SPTagsListSectionTags || proposedDestinationIndexPath.section != SPTagsListSectionTags) {

        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath ? proposedDestinationIndexPath : sourceIndexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return self.bEditing ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
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
    [self renameTagAction:[self tagAtIndexPath:path]];
}

- (void)tagListViewCellShouldDeleteTag:(SPTagListViewCell *)cell {
    
    [SPTracker trackTagMenuDeleted];
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    [self removeTagAtIndexPath:path];
}

- (void)setEditing:(BOOL)editing canceled:(BOOL)isCanceled {
    
    if (self.bEditing == editing) {
        return;
    }
    
    self.bEditing = editing;

    self.tableView.allowsSelectionDuringEditing = YES;
    [self.tableView setEditing:editing animated:YES];
    
    if (editing) {
        [self.editTagsButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
		[SPTracker trackTagEditorAccessed];
    } else {
        [self.editTagsButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
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
        [UIView animateWithDuration:UIKitConstants.animationShortDuration
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
        SPTagListViewCell *cell = (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForTag:_renameTag]];
        [cell.tagNameTextField endEditing:YES];
    }
    
    [self setEditing:NO canceled:NO];
}

- (void)openNoteListForTagName:(NSString *)tag {
    
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
    
    Tag *tag = [self tagAtIndexPath:indexPath];
    if (!tag) {
        return;
    }
    
    // see if this is the current tag
	SPAppDelegate *appDelegate = [SPAppDelegate sharedDelegate];
    if ([appDelegate.selectedTag isEqual:tag.name]) {
        appDelegate.selectedTag = nil;
        [appDelegate.noteListViewController update];
    }
    
    BOOL lastTag = [self numberOfTags] == 1;

    if ([[SPObjectManager sharedManager] removeTag:tag] && !lastTag) {
        
        [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
}

- (void)renameTagAction:(Tag *)tag {
    
    if (_renameTag) {
        SPTagListViewCell *cell = (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForTag:_renameTag]];
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
    
    if (string) {
        [textField setText:[textField.text stringByReplacingCharactersInRange:range
                                                              withString:string]];
    }
    
    if (endEditing) {
        [textField endEditing:YES];
    }
    
    return NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    SPTagListViewCell *cell = (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForTag:_renameTag]];
    if (self.bEditing) {
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
    else {
        textField.text = _renameTag.name;
    }
    
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
    
    self.bVisible = NO;
    [self setEditing:NO canceled:YES];
    
}
- (void)containerViewControllerDidShowSidePanel:(SPSidebarContainerViewController *)container {
    
    self.bVisible = YES;
}

- (BOOL)containerViewControllerShouldShowSidePanel:(SPSidebarContainerViewController *)container {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.bVisible) {
            [self.tableView reloadData];
        }
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

- (NSArray *)sortDescriptors {

    BOOL isAlphaSort = [[NSUserDefaults standardUserDefaults] boolForKey:SPAlphabeticalTagSortPref];
    NSSortDescriptor *sortDescriptor;
    if (isAlphaSort) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                     ascending:YES
                                                      selector:@selector(localizedCaseInsensitiveCompare:)];
    } else {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    }

    return @[sortDescriptor];
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

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
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
    
    if (!self.bVisible) {
        return;
    }
    
    [self.reloadTimer invalidate];
    self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(delayedReloadData)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void)delayedReloadData {
    
    [self.tableView reloadData];
    
    [self.reloadTimer invalidate];
    self.reloadTimer = nil;
}


#pragma mark - KeyboardNotifications

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardFrame = [(NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = MIN(keyboardFrame.size.height, keyboardFrame.size.width);
    
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height = newFrame.size.height - keyboardHeight;
    
    CGFloat animationDuration = [(NSNumber *)[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
         self.tableView.frame = newFrame;
     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height = self.view.superview.frame.size.height - self.view.frame.origin.y;

    CGFloat animationDuration = [(NSNumber *)[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
         self.tableView.frame = newFrame;
     }];
}


#pragma mark - Interface Setup

- (UIView *)buildTableHeaderView {
    CGRect headerFrame = CGRectMake(0, 0, 0, 40);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];

    UIView *tagsView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 0, 20)];
    tagsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.tagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 0, 20)];
    self.tagsLabel.font = [UIFont systemFontOfSize: 14];
    self.tagsLabel.text = [NSLocalizedString(@"Tags", nil) uppercaseString];
    self.tagsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [tagsView addSubview:self.tagsLabel];

    self.editTagsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.editTagsButton.frame = CGRectMake(0, 0, 0, 20);
    self.editTagsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    self.editTagsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.editTagsButton.titleLabel setFont: [UIFont systemFontOfSize: 14]];
    self.editTagsButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    [self.editTagsButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
    [self.editTagsButton addTarget:self action:@selector(editTagsTap:) forControlEvents:UIControlEventTouchUpInside];
    [tagsView addSubview:self.editTagsButton];

    [self updateHeaderColors];

    [headerView addSubview:tagsView];
    
    return headerView;
}

- (void)updateSortOrder:(id)sender {
    self.fetchedResultsController.fetchRequest.sortDescriptors = [self sortDescriptors];

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self.tableView reloadData];
}

@end

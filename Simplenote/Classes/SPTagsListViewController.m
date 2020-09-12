#import "SPTagsListViewController.h"
#import "SPAppDelegate.h"
#import "SPOptionsViewController.h"
#import "SPObjectManager.h"
#import "SPTracker.h"
#import "SPTagListViewCell.h"
#import "Tag.h"

#import "VSThemeManager.h"
#import <Simperium/Simperium.h>
#import "Simplenote-Swift.h"


// MARK: - Constants
//
typedef NS_ENUM(NSInteger, SPTagsListSection) {
    SPTagsListSectionSystem     = 0,
    SPTagsListSectionTags       = 1,
    SPTagsListSectionBottom     = 2,
    SPTagsListSectionCount      = 3
};

typedef NS_ENUM(NSInteger, SPTagsListSystemRow) {
    SPTagsListSystemRowAllNotes = 0,
    SPTagsListSystemRowTrash    = 1,
    SPTagsListSystemRowSettings = 2,
    SPTagsListSystemRowCount    = 3
};

typedef NS_ENUM(NSInteger, SPTagsListBottomRow) {
    SPTagsListBottomRowUntagged = 0,
    SPTagsListBottomRowCount    = 1
};

static const NSInteger SPTagListRequestBatchSize        = 20;
static const NSTimeInterval SPTagListRefreshDelay       = 0.5;
static const NSInteger SPTagListEmptyStateSectionCount  = 1;



// MARK: - Private
//
@interface SPTagsListViewController () <NSFetchedResultsControllerDelegate,
                                        SPTagListViewCellDelegate,
                                        UIGestureRecognizerDelegate,
                                        UITextFieldDelegate,
                                        UITableViewDelegate,
                                        UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView          *tableView;
@property (nonatomic, strong) IBOutlet UIView               *rightBorderView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint   *rightBorderWidthConstraint;
@property (nonatomic, strong) SPTagHeaderView               *tagsHeaderView;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) Tag                           *renameTag;
@property (nonatomic, strong) NSTimer                       *reloadTimer;
@property (nonatomic, assign) BOOL                          bVisible;

@end


// MARK: - SPTagsListViewController Implementation
//
@implementation SPTagsListViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureView];
    [self configureTableView];
    [self configureTableHeaderView];
    [self configureRightBorderView];
    [self configureMenuController];
    [self startListeningToNotifications];

    [self refreshStyle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startListeningToKeyboardNotifications];
    [self reloadDataAsynchronously];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.bVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setEditing:NO canceled:YES];
    [self stopListeningToKeyboardNotifications];
    self.bVisible = NO;
}


#pragma mark - Overridden Methods

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Interface Initialization

- (void)configureView {
    self.view.backgroundColor = [UIColor simplenoteBackgroundColor];
}

- (void)configureTableView {
    [self.tableView registerNib:[SPTagListViewCell loadNib] forCellReuseIdentifier:[SPTagListViewCell reuseIdentifier]];

    if (@available(iOS 13.0, *)) {
        self.tableView.automaticallyAdjustsScrollIndicatorInsets = NO;
    }
}

- (void)configureTableHeaderView {
    self.tagsHeaderView = (SPTagHeaderView *)[SPTagHeaderView loadFromNib];
    self.tagsHeaderView.titleLabel.text = NSLocalizedString(@"Tags", nil);
    self.tagsHeaderView.titleLabel.font = [UIFont preferredFontFor:UIFontTextStyleTitle2 weight:UIFontWeightBold];

    UIButton *actionButton = self.tagsHeaderView.actionButton;
    [actionButton setTitle:NSLocalizedString(@"Edit", @"Edit Tags Action: Visible in the Tags List") forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(editTagsTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureRightBorderView {
    self.rightBorderWidthConstraint.constant = UIScreen.mainScreen.pointToPixelRatio;
}

- (void)configureMenuController {
    SEL renameSelector = sel_registerName("rename:");
    UIMenuItem *renameItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename", @"Rename a tag")
                                                        action:renameSelector];
    [[UIMenuController sharedMenuController] setMenuItems:@[renameItem]];
    [[UIMenuController sharedMenuController] update];
}


#pragma mark - Notification Hooks

- (void)startListeningToNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(menuDidChangeVisibility:) name:UIMenuControllerDidHideMenuNotification object:nil];
    [nc addObserver:self selector:@selector(menuDidChangeVisibility:) name:UIMenuControllerDidShowMenuNotification object:nil];
    [nc addObserver:self selector:@selector(tagsSortOrderWasUpdated:) name:SPAlphabeticalTagSortPreferenceChangedNotification object:nil];
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


#pragma mark - Notification Handlers

- (void)themeDidChange {
    [self refreshStyle];
}

- (void)menuDidChangeVisibility:(UIMenuController *)menuController {
    self.tableView.allowsSelection = ![UIMenuController sharedMenuController].menuVisible;
}

- (void)tagsSortOrderWasUpdated:(id)sender {
    [self refreshSortDescriptorsAndPerformFetch];
}


#pragma mark - Style

- (void)refreshStyle {
    self.rightBorderView.backgroundColor = [UIColor simplenoteDividerColor];
    [self.tagsHeaderView refreshStyle];
    [self.tableView applySimplenotePlainStyle];
    [self.tableView reloadData];
}


#pragma mark - Button actions

- (void)editTagsTap:(UIButton *)sender {
    BOOL newState = !self.isEditing;
    if (newState) {
        [SPTracker trackTagEditorAccessed];
    }

    [self setEditing:newState canceled:NO];
}


#pragma mark - Helper Methods

- (SPTagListViewCell *)cellForTag:(Tag *)tag {
    NSIndexPath *indexPath = [self tableViewIndexPathForTag:tag];
    return (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)tableViewIndexPathForTag:(Tag *)tag {
    NSInteger row = [self.fetchedResultsController indexPathForObject:tag].row;
    return [NSIndexPath indexPathForItem:row inSection:SPTagsListSectionTags];
}

- (Tag *)tagAtTableViewIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.fetchedResultsController.fetchedObjects.count || indexPath.section != SPTagsListSectionTags) {
        return nil;
    }

    // Our FRC has just one section!
    NSIndexPath *resultsIndexPah = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    return [self.fetchedResultsController objectAtIndexPath:resultsIndexPah];
}

- (NSInteger)numberOfTags {
    return self.fetchedResultsController.sections.firstObject.numberOfObjects;
}

- (void)reloadDataAsynchronously {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == SPTagsListSectionTags ? UITableViewAutomaticDimension : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return section == SPTagsListSectionTags ? self.tagsHeaderView : nil;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isTagRow = indexPath.section == SPTagsListSectionTags;
    BOOL isSortEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:SPAlphabeticalTagSortPref];

    return isTagRow && !isSortEnabled;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.numberOfTags == 0) ? SPTagListEmptyStateSectionCount : SPTagsListSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case SPTagsListSectionSystem:
            return SPTagsListSystemRowCount;

        case SPTagsListSectionTags:
            return self.numberOfTags;

        case SPTagsListSectionBottom:
            return SPTagsListBottomRowCount;

        default:
            NSAssert(false, @"Unsupported section");
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPTagListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SPTagListViewCell.reuseIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.selected = [self shouldSelectCellAtIndexPath:indexPath];
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
    switch (indexPath.section) {
        case SPTagsListSectionSystem:
            [self didSelectSystemRowAtIndexPath:indexPath];
            break;

        case SPTagsListSectionTags:
            [self didSelectTagAtIndexPath:indexPath];
            break;

        case SPTagsListSectionBottom:
            [self didSelectBottomRowAtIndex:indexPath];
            break;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section == SPTagsListSectionTags && destinationIndexPath.section == SPTagsListSectionTags) {
        [[SPObjectManager sharedManager] moveTagFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (sourceIndexPath.section != SPTagsListSectionTags || proposedDestinationIndexPath.section != SPTagsListSectionTags) {
        return sourceIndexPath;
    }
    
    return proposedDestinationIndexPath ?: sourceIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == SPTagsListSectionTags;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isTagRow = indexPath.section == SPTagsListSectionTags;
    return isTagRow && tableView.isEditing ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SPTracker trackTagRowDeleted];
		[self removeTagAtIndexPath:indexPath];
    }
}


#pragma mark - Cell Setup

- (void)configureCell:(SPTagListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SPTagsListSectionSystem:
            [self configureSystemCell:cell atIndexPath:indexPath];
            break;

        case SPTagsListSectionTags:
            [self configureTagCell:cell atIndexPath:indexPath];
            break;

        case SPTagsListSectionBottom:
            [self configureBottomCell:cell atIndexPath:indexPath];
            break;
    }
}

- (void)configureSystemCell:(SPTagListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SPTagsListSystemRowAllNotes:
            cell.textField.text = NSLocalizedString(@"All Notes", nil);
            cell.iconImage = [UIImage imageWithName:UIImageNameAllNotes];
            cell.accessibilityIdentifier = @"all-notes";
            break;

        case SPTagsListSystemRowTrash:
            cell.textField.text = NSLocalizedString(@"Trash-noun", nil);
            cell.iconImage = [UIImage imageWithName:UIImageNameTrash];
            break;

        case SPTagsListSystemRowSettings:
            cell.textField.text = NSLocalizedString(@"Settings", nil);
            cell.iconImage = [UIImage imageWithName:UIImageNameSettings];
            cell.accessibilityIdentifier = @"settings";
            break;
    }
}

- (void)configureTagCell:(SPTagListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *tagName = [self tagAtTableViewIndexPath:indexPath].name;

    cell.textField.text = tagName;
    cell.textField.delegate = self;
    cell.iconImage = nil;
    cell.delegate = self;
}

- (void)configureBottomCell:(SPTagListViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textField.text = NSLocalizedString(@"Untagged Notes", @"Allows selecting notes with no tags");
    cell.iconImage = [UIImage imageWithName:UIImageNameUntagged];
}

- (BOOL)shouldSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedTag = SPAppDelegate.sharedDelegate.selectedTag;

    switch (indexPath.section) {
        case SPTagsListSectionSystem:
            switch (indexPath.row) {
                case SPTagsListSystemRowAllNotes:
                    return selectedTag == nil;
                case SPTagsListSystemRowTrash:
                    return selectedTag == kSimplenoteTrashKey;
                case SPTagsListSystemRowSettings:
                    return NO;
            }
            break;

        case SPTagsListSectionTags:
            return selectedTag == [self tagAtTableViewIndexPath:indexPath].name;

        case SPTagsListSectionBottom:
            return selectedTag == kSimplenoteUntaggedKey;
    }

    return NO;
}


#pragma mark - Row Press Handlers

- (void)didSelectSystemRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SPTagsListSystemRowAllNotes:
            [self allNotesWasPressed];
            break;

        case SPTagsListSystemRowTrash:
            [self trashWasPressed];
            break;

        case SPTagsListSystemRowSettings:
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self settingsWasPressed];
            break;
    }
}

- (void)didSelectTagAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = [self tagAtTableViewIndexPath:indexPath];

    if (self.isEditing) {
        [SPTracker trackTagRowRenamed];
        [self renameTagAction:tag];
    } else {
        [SPTracker trackListTagViewed];
        [self openNoteListForTagName:tag.name];
    }
}

- (void)didSelectBottomRowAtIndex:(NSIndexPath *)indexPath {
    [SPTracker trackListUntaggedViewed];
    [self openNoteListForTagName:kSimplenoteUntaggedKey];
}

- (void)allNotesWasPressed {
    [self openNoteListForTagName:nil];
}

- (void)trashWasPressed {
    [SPTracker trackTrashViewed];
    [self openNoteListForTagName:kSimplenoteTrashKey];
}

- (void)settingsWasPressed {
    [[SPAppDelegate sharedDelegate] showOptions];
}


#pragma mark - UITagListViewCellDelegate

- (void)tagListViewCellShouldRenameTag:(SPTagListViewCell *)cell {
    [SPTracker trackTagMenuRenamed];
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    [self renameTagAction:[self tagAtTableViewIndexPath:path]];
}

- (void)tagListViewCellShouldDeleteTag:(SPTagListViewCell *)cell {
    [SPTracker trackTagMenuDeleted];
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    [self removeTagAtIndexPath:path];
}

- (void)setEditing:(BOOL)editing canceled:(BOOL)isCanceled {
    // Note: Neither super.setEditing nor tableView.setEditing will resign the first responder.
    if (!editing) {
        [self.view endEditing:YES];
    }

    [super setEditing:editing animated:YES];
    [self.tableView setEditing:editing animated:YES];
    [self refreshEditTagsButtonForEditionState:editing];
}

- (void)refreshEditTagsButtonForEditionState:(BOOL)editing {
    NSString *title = editing ? NSLocalizedString(@"Done", nil) : NSLocalizedString(@"Edit", nil);
    [self.tagsHeaderView.actionButton setTitle:title forState:UIControlStateNormal];
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

    [[[SPAppDelegate sharedDelegate] sidebarViewController] hideSidebarWithAnimation:YES];
}


#pragma mark - UIGestureDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - Tag Actions

- (void)removeTagAtIndexPath:(NSIndexPath *)indexPath {
    Tag *tag = [self tagAtTableViewIndexPath:indexPath];
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
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
}

- (void)renameTagAction:(Tag *)tag {
    if (self.renameTag) {
        SPTagListViewCell *cell = [self cellForTag:self.renameTag];
        [cell.textField endEditing:YES];
    }
    
    self.renameTag = tag;
    
    // begin editing the text field
    SPTagListViewCell *cell = [self cellForTag:tag];

    cell.textField.enabled = YES;
    [cell.textField becomeFirstResponder];
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Scenario #A: Space was pressed
    if ([string hasPrefix:@" "]) {
        [textField endEditing:YES];
        return NO;
    }

    // Scenario #B: New String was either typed or pasted
    NSString *filteredString = [string substringUpToFirstSpace];
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:filteredString];
    BOOL editContainsSpaces = filteredString.length < string.length;

    if (updatedString.isValidTagName) {
        textField.text = updatedString;
    }

    if (editContainsSpaces) {
        [textField endEditing:YES];
    }

    return NO;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    SPTagListViewCell *cell = [self cellForTag:self.renameTag];
    if (self.isEditing) {
        [cell setSelected:NO animated:YES];
    }

    // see if tag already exists, if not rename. If it does, revert back to original name
    BOOL renameTag = ![[SPObjectManager sharedManager] tagExists:textField.text];
    
    if (renameTag) {
        NSString *orignalTagName = self.renameTag.name;
        NSString *newTagName = textField.text;
        [[SPObjectManager sharedManager] editTag:self.renameTag title:newTagName];
        
        // see if this is the current tag
		SPAppDelegate *appDelegate = [SPAppDelegate sharedDelegate];
        if ([appDelegate.selectedTag isEqual:orignalTagName]) {
            appDelegate.selectedTag = newTagName;
            [appDelegate.noteListViewController update];
        }
    }
    else {
        textField.text = self.renameTag.name;
    }
    
    self.renameTag = nil;

    cell.textField.text = textField.text;
    cell.textField.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}
    
    [self.tableView reloadData];
}

- (void)refreshSortDescriptorsAndPerformFetch {
    self.fetchedResultsController.fetchRequest.sortDescriptors = [self sortDescriptors];
    [self performFetch];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];

    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = SPTagListRequestBatchSize;
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


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!self.bVisible) {
        return;
    }
    
    [self.reloadTimer invalidate];
    self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:SPTagListRefreshDelay
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
    CGRect keyboardFrame = [(NSValue *)notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [(NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    CGFloat keyboardHeight = MIN(keyboardFrame.size.height, keyboardFrame.size.width);

    contentInsets.bottom = keyboardHeight;
    scrollInsets.bottom = keyboardHeight;

    [UIView animateWithDuration:duration animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollInsets;
     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;

    contentInsets.bottom = safeAreaInsets.bottom;

    CGFloat duration = [(NSNumber *)notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
     }];
}

@end

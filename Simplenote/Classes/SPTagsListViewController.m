//
//  SPTagsListViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 7/23/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

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
#import "SPTracker.h"

#define kSectionAllNotes 0
#define kSectionTrash 2
#define kSectionTags 1
#define kSectionEdit 3
#define kSectionSettings 4

#define kActionSheetDeleteIndex 0
#define kActionSheetRenameIndex 1
#define kActionSheetCancelIndex 2

static NSString * const SPTagTrashKey = @"trash";


@interface SPTagsListViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) Tag *renameTag;
@property (nonatomic, strong) UIImage *tagImage;
@property (nonatomic, strong) UIImage *allNotesImage;
@property (nonatomic, strong) UIImage *trashImage;
@property (nonatomic, strong) UIImage *settingsImage;
@property (nonatomic, strong) UIImage *sortImage;


@end

@implementation SPTagsListViewController
@synthesize fetchedResultsController=__fetchedResultsController;

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    
    if (!customView) {
        customView = [[SPBorderedView alloc] init];
        customView.fillColor = [self.theme colorForKey:@"backgroundColor"];
        customView.borderColor = [self.theme colorForKey:@"tagListSeparatorColor"];
        customView.showLeftBorder = NO;
        customView.showBottomBorder = NO;
        customView.showTopBorder = NO;
        customView.showRightBorder = NO;
        self.view = customView;
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // apply styling
    self.view.backgroundColor = [self.theme colorForKey:@"backgroundColor"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _tagImage = [[UIImage imageNamed:@"icon_tag"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _settingsImage = [[UIImage imageNamed:@"icon_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _allNotesImage = [[UIImage imageNamed:@"icon_allnotes"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _trashImage = [[UIImage imageNamed:@"icon_trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _sortImage = [[UIImage imageNamed:@"icon_sort"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    // add rename item to manu
    SEL renameSelector = sel_registerName("rename:");
    UIMenuItem *renameItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename", @"Rename a tag")
                                                        action:renameSelector];
    [[UIMenuController sharedMenuController] setMenuItems:@[renameItem]];
    [[UIMenuController sharedMenuController] update];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidChangeVisibility:)
                                                 name:UIMenuControllerDidHideMenuNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidChangeVisibility:)
                                                 name:UIMenuControllerDidShowMenuNotification
                                               object:nil];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(themeDidChange) name:VSThemeManagerThemeDidChangeNotification object:nil];
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (void)themeDidChange {
    customView.fillColor = [self.theme colorForKey:@"backgroundColor"];
    customView.borderColor = [self.theme colorForKey:@"tagListSeparatorColor"];

    self.view.backgroundColor = [self.theme colorForKey:@"backgroundColor"];

    cellIdentifier = self.theme.name;
    cellWithIconIdentifier = [self.theme.name stringByAppendingString:@"WithIcon"];
    [self.tableView reloadData];

    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
}

- (void)menuDidChangeVisibility:(UIMenuController *)menuController {
    
    self.tableView.allowsSelection = ![UIMenuController sharedMenuController].menuVisible;
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
    
    if (section == kSectionSettings || section == kSectionEdit)
        return 1;
    else if ((section == kSectionTrash || section == kSectionTags) &&
             self.fetchedResultsController.fetchedObjects.count == 0)
        return 1;
    
    return 10;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == kSectionTrash || section == kSectionEdit)
        return 1;
    
    return 10;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == kSectionAllNotes || section == kSectionTrash || section == kSectionSettings)
		return bEditing ? 0 : 1;
    else if (section == kSectionEdit)
        return (self.numTags == 0 || bEditing) ? 0 : 1;
	else if (section == kSectionTags)
		return [self numTags];
    
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTagListViewCell *cell;
    if (indexPath.section == kSectionTags) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (!cell) {
            cell = [[SPTagListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
                
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellWithIconIdentifier];

        if (!cell) {
            cell = [[SPTagListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellWithIconIdentifier];
        }
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
    
    if (indexPath.section == kSectionAllNotes) {
        
        cellText = NSLocalizedString(@"All Notes", @"Title of option to display all notes");
        cellIcon = _allNotesImage;
        
        selected = [SPAppDelegate sharedDelegate].selectedTag == nil;
        
    } else if (indexPath.section == kSectionTrash) {
        
        // Set up the cell...
        cellText = NSLocalizedString(@"Trash-noun", @"Trash (noun) - the location where deleted notes are stored");
        cellIcon = _trashImage;
        
        selected = [[SPAppDelegate sharedDelegate].selectedTag  isEqual:@"trash"];
        
    } else if (indexPath.section == kSectionTags) {
        Tag *tag = [self tagAtRow: indexPath.row];
        
        cellText = tag.name;
        cellIcon = nil;
        
        cell.accessoryType = bEditing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        
        selected = bEditing ? NO : [[SPAppDelegate sharedDelegate].selectedTag isEqualToString:tag.name];
        
    } else if (indexPath.section == kSectionSettings) {
        
        cellText = NSLocalizedString(@"Settings", nil);
        cellIcon = _settingsImage;
        
        selected = NO;
        
        
    } else if (indexPath.section == kSectionEdit) {
        
        cellText = NSLocalizedString(@"Edit Tags", @"Re-order or delete tags");
        cellIcon = _sortImage;
        
        selected = NO;
    }
    
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
    
    if (indexPath.section == kSectionAllNotes) {
        
        [self openNoteListForTagName:nil];
        
    } else if (indexPath.section == kSectionTrash) {
        
        [SPTracker trackTrashViewed];
        [self openNoteListForTagName:SPTagTrashKey];
        
    }else if (indexPath.section == kSectionTags) {
        
        Tag *tag = [self tagAtRow: indexPath.row];

        if (bEditing) {
            [SPTracker trackTagRowRenamed];
            [self renameTagAction:tag];
        } else {
            [SPTracker trackListTagViewed];
            [self openNoteListForTagName:tag.name];
		}
        
    } else if (indexPath.section == kSectionSettings) {
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [[SPAppDelegate sharedDelegate] showOptions];

    } else if (indexPath.section == kSectionEdit) {
        [self setEditing:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section == kSectionTags;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.section == kSectionTags;
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
    if (indexPath.section == kSectionTags && bEditing)
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


#pragma mark UITagListViewCellDelegate

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

- (void)setEditing:(BOOL)editing {
    
    if (bEditing == editing) {
        return;
    }
    
    bEditing = editing;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    
    UIView *snapshot = [self.tableView snapshotViewAfterScreenUpdates:NO];
    snapshot.frame = self.tableView.frame;
    snapshot.contentMode = UIViewContentModeTop;
    [self.view insertSubview:snapshot aboveSubview:self.tableView];
    self.tableView.alpha = 0.0;
    
    [self.tableView setEditing:editing animated:NO];
    [self.tableView reloadData];
    
    if (editing) {
        
		[SPTracker trackTagEditorAccessed];
		      
        SPSidebarContainerViewController *noteListViewController = (SPSidebarContainerViewController *)[[SPAppDelegate sharedDelegate] noteListViewController];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingAction:)];
        doneButton.accessibilityHint = @"Finish editing tags";
        
        [noteListViewController showFullSidePanelWithTemporaryBarButton:doneButton
                                                             completion:nil];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             snapshot.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [snapshot removeFromSuperview];
                         }];
        
        CGRect newTableViewFrame = self.tableView.frame;
        newTableViewFrame.size.width = MIN(self.view.bounds.size.width, 500);
        newTableViewFrame.origin.x = (self.view.bounds.size.width - newTableViewFrame.size.width) / 2.0;
        self.tableView.frame = newTableViewFrame;
        
        CGFloat borderInsetLength = newTableViewFrame.origin.x - customView.borderWidth;;
        customView.borderInset = UIEdgeInsetsMake(0, borderInsetLength, 0, borderInsetLength);
        customView.showLeftBorder = YES;
        customView.showRightBorder = YES;
        [customView setNeedsDisplay];
        
        [UIView animateWithDuration:0.3
                              delay:0.05
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.tableView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             nil;
                         }];

    } else {
        
        if (bVisible) {
            [[self containerViewController] showSidePanel:nil];
        }
        
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
        
        customView.showLeftBorder = NO;
        customView.showRightBorder = NO;
        [customView setNeedsDisplay];

        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             snapshot.alpha = 0.0;
                             self.tableView.alpha = 1.0;
                             
                         } completion:^(BOOL finished) {
                             [snapshot removeFromSuperview];
                         }];
        

        
        // scroll editing cell to visible
        if (self.fetchedResultsController.fetchedObjects.count > 0)
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kSectionEdit]
                                  atScrollPosition:UITableViewScrollPositionMiddle
                                          animated:NO];
        
    }
    
    
    return;
}

- (void)doneEditingAction:(id)sender {
    
    if (_renameTag) {
        
        SPTagListViewCell *cell = (SPTagListViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self rowForTag:_renameTag] inSection:kSectionTags]];
        [cell.tagNameTextField endEditing:YES];
    }
    
    [self setEditing:NO];
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

#pragma UIGestureDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}


#pragma mark tag actions 


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



#pragma mark UITextFieldDelegate methods

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

#pragma mark sidePanelDelegate

- (void)containerViewControllerDidHideSidePanel:(SPSidebarContainerViewController *)container {
    
    bVisible = NO;
    [self setEditing:NO];
    
}
- (void)containerViewControllerDidShowSidePanel:(SPSidebarContainerViewController *)container {
    
    bVisible = YES;
}

- (BOOL)containerViewControllerShouldShowSidePanel:(SPSidebarContainerViewController *)container {
    
    self.tableView.frame = self.view.bounds;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (!bVisible)
            [self.tableView reloadData];
    });
    
    return YES;
}

- (void)containerViewController:(SPSidebarContainerViewController *)container didChangeContentInset:(UIEdgeInsets)contentInset {
    
    self.tableView.contentInset = contentInset;
    self.tableView.scrollIndicatorInsets = contentInset;
    self.tableView.contentOffset = CGPointMake(0, -contentInset.top);
}



#pragma mark - Fetched results controller

- (NSArray *)sortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    return sortDescriptors;
}

- (void)performFetch {
    
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
	NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [self sortDescriptors];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [self performFetch];
    
    return __fetchedResultsController;
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

#pragma mark KeyboardNotifications	

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardFrame = [(NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = MIN(keyboardFrame.size.height, keyboardFrame.size.width);
    
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height -= keyboardHeight + [self.theme floatForKey:@"editorViewAboveKeyboardPadding"];
    
    CGFloat animationDuration = [(NSNumber *)[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.tableView.frame = newFrame;
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height = self.view.superview.frame.size.height - self.view.frame.origin.y;

    CGFloat animationDuration = [(NSNumber *)[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         self.tableView.frame = newFrame;
                     }];
    
}

@end

//
//  SPAddCollaboratorsViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 7/27/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPAddCollaboratorsViewController.h"
#import "SPEntryListCell.h"
#import "SPEntryListAutoCompleteCell.h"
#import "VSThemeManager.h"
#import "NSString+Metadata.h"
#import "PersonTag.h"
#import "SPAddressBookManager.h"

@implementation SPAddCollaboratorsViewController

- (id<SPCollaboratorDelegate>)collaboratorDelegate
{
    return collaboratorDelegate;
}
- (void)setCollaboratorDelegate:(id<SPCollaboratorDelegate>)newCollaboratorDelegate
{
    collaboratorDelegate = newCollaboratorDelegate;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set navigation bar
    self.navigationItem.title = NSLocalizedString(@"Collaborators", @"Noun - collaborators are other Simplenote users who you chose to share a note with");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onDone)];
    
    entryTextField.placeholder = NSLocalizedString(@"Add a new collaborator...", @"Noun - collaborators are other Simplenote users who you chose to share a note with");

    if (!self.dataSource)
        self.dataSource = [NSMutableArray arrayWithCapacity:3];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [primaryTableView reloadData];
    
    hasPermissions = [[SPAddressBookManager sharedManager] authorizationStatus] == kABAuthorizationStatusAuthorized;
    
    if (hasPermissions)
        [[SPAddressBookManager sharedManager] loadPeople];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
 
    [super viewDidAppear:animated];
    
    if ([[SPAddressBookManager sharedManager] authorizationStatus] == kABAuthorizationStatusNotDetermined)
        [[SPAddressBookManager sharedManager] requestAddressBookPermissions:^(BOOL success) {
            
            hasPermissions = success;
            
        }];
    else if (!(self.dataSource.count > 0)) {
        
        // GDC is used to call becomeFirstResponder asynchronously to fix
        // a layout issue on iPad in landscape. Views presented as a UIModalPresentationFormSheet
        // and present a keyboard in viewDidAppear layout incorrectly
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [entryTextField becomeFirstResponder];
        });
    }

}

- (void)setupWithCollaborators:(NSArray *)collaborators {
    
    NSInteger count = collaborators.count;
    self.dataSource = [NSMutableArray arrayWithCapacity:(count > 0 ? count : 2)];
    
    for (NSString *tag in collaborators) {
        
        NSArray *matchingPeople = [[SPAddressBookManager sharedManager] matchingPeopleForString:tag filterOutPeople:nil];
        
        PersonTag *person;
        if (matchingPeople.count == 1)
            person = matchingPeople[0];
        else
            person = [[PersonTag alloc] initWithName:nil
                                               email:tag];
        
        person.active = YES;
        [self.dataSource addObject:person];
        
    }
    
    [primaryTableView reloadData];
}


#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual:primaryTableView])
        return self.dataSource.count;
    else
        return [super tableView:tableView numberOfRowsInSection:section];
    
    return 0;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([tableView isEqual:primaryTableView])
        return self.dataSource.count > 0 ? NSLocalizedString(@"Current Collaborators", nil) : nil;
    else
        return [super tableView:tableView titleForHeaderInSection:section];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if ([tableView isEqual:primaryTableView])
        return self.dataSource.count > 0? nil : NSLocalizedString(@"collaborators-description", nil);
    else
        return [super tableView:tableView titleForFooterInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SPEntryListCell *cell = (SPEntryListCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    PersonTag *personTag;
    if ([tableView isEqual:primaryTableView])
        personTag = self.dataSource[indexPath.row];
    else
        personTag = self.autoCompleteDataSource[indexPath.row];
    
    BOOL hasName = personTag.name.length > 0;
    NSString *primaryText = hasName ? personTag.name : personTag.email;
    NSString *secondaryText = hasName ? personTag.email : nil;
    
    [cell setupWithPrimaryText:primaryText
                 secondaryText:secondaryText
                   checkmarked:personTag.active];
    
    return cell;
    
}

- (void)removeItemFromDataSourceAtIndexPath:(NSIndexPath *)indexPath {
    
    PersonTag *person = self.dataSource[indexPath.row];
    [collaboratorDelegate collaboratorViewController:self
                               didRemoveCollaborator:person.email];
    
    [super removeItemFromDataSourceAtIndexPath:indexPath];
}

#pragma mark UITableViewDelegate Methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if ([tableView isEqual:primaryTableView]) {

        PersonTag *person = self.dataSource[indexPath.row];
        person.active = !person.active;
        
        if (person.active)
            [collaboratorDelegate collaboratorViewController:self
                                          didAddCollaborator:person.email];
        else
            [collaboratorDelegate collaboratorViewController:self
                                       didRemoveCollaborator:person.email];
        
        [tableView reloadData];
        
    } else if ([tableView isEqual:autoCompleteTableView]) {
        
        PersonTag *person = self.autoCompleteDataSource[indexPath.row];
        [self addPersonTag:person];
    }
    
}


- (void)addPersonTag:(PersonTag *)person {
    
    // make sure email address is actually an email address
    person.email = [person.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![person.email containsEmailAddress])
        return;
    
    // check to see from delegate if should add collaborator
    if ([collaboratorDelegate collaboratorViewController:self
                                   shouldAddCollaborator:person.email]) {
        [collaboratorDelegate collaboratorViewController:self
                                      didAddCollaborator:person.email];
        
        person.active = YES;
        [self.dataSource addObject:person];
        
        entryTextField.text = @"";
        [primaryTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self updateAutoCompleteMatchesForString:nil];
        
    }
}

- (void)processTextInField {
    
    // make sure text is an email address
    
    UITextField *textField = entryTextField;
    if ([textField.text containsEmailAddress]) {
        
        NSString *email = textField.text;
        
        // check to see if this person is in the addressbook
        NSArray *matchingPeople = [[SPAddressBookManager sharedManager] matchingPeopleForString:email filterOutPeople:nil];
        
        PersonTag *person;
        if (matchingPeople.count == 1)
            person = matchingPeople[0];
        else
            person = [[PersonTag alloc] initWithName:nil
                                               email:email];
        
        [self addPersonTag:person];
        
    }
}


- (void)updateAutoCompleteMatchesForString:(NSString *)string {
    
    if (!hasPermissions)
        return;
    
    if (string.length > 0) {
        self.autoCompleteDataSource = [[SPAddressBookManager sharedManager] matchingPeopleForString:string
                                                                             filterOutPeople:self.dataSource];
    } else {
        self.autoCompleteDataSource = nil;
    }
    
    [self updatedAutoCompleteMatches];
}

#pragma mark - Buttons

- (void)onDone
{
    [self processTextInField];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods

- (void)peoplePickerNavigationControllerDidCancel: (ABPeoplePickerNavigationController *)peoplePicker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    // see if only 1 email address exists. If so, dismiss picker
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emailAddresses) > 1) {
        CFRelease(emailAddresses);
        return YES;
    }
    
    [self createPeronTagFromPerson:person emailIdentifier:0];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    CFRelease(emailAddresses);
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    [self createPeronTagFromPerson:person emailIdentifier:identifier];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (void)createPeronTagFromPerson:(ABRecordRef)person emailIdentifier:(ABMultiValueIdentifier)identifier {
    
    NSString* name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
    
    NSString* email = nil;
    ABMultiValueRef emailAddresses = ABRecordCopyValue(person,
                                                       kABPersonEmailProperty);
    if (ABMultiValueGetCount(emailAddresses) > 0) {
        email = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(emailAddresses,identifier);
    }
    
    CFRelease(emailAddresses);
    
    
    if (email.length > 0) {
        PersonTag *personTag = [[PersonTag alloc] initWithName:name email:email];
        [self addPersonTag:personTag];
    }
}

- (void)entryFieldPlusButtonTapped:(id)sender {
    
    [self showAddressPickerAction:sender];
}

- (void)showAddressPickerAction:(id)sender {
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.displayedProperties = @[[NSNumber numberWithInt:kABPersonEmailProperty]];
    picker.peoplePickerDelegate = self;
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:picker
                                            animated:YES
                                          completion:nil];
    
}


@end

#import "SPAddCollaboratorsViewController.h"
#import "SPEntryListCell.h"
#import "SPEntryListAutoCompleteCell.h"
#import "NSString+Metadata.h"
#import "PersonTag.h"
#import <ContactsUI/ContactsUI.h>
#import "Simplenote-Swift.h"



#pragma mark - Private Helpers

@interface SPAddCollaboratorsViewController () <CNContactPickerDelegate>
@property (nonatomic, strong) SPContactsManager *contactsManager;
@end


#pragma mark - Implementation

@implementation SPAddCollaboratorsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupContactsManager];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self setupNavigationItem];
    [self setupTextFields];

    if (!self.dataSource) {
        self.dataSource = [NSMutableArray arrayWithCapacity:3];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [primaryTableView reloadData];
    [self.contactsManager requestAuthorizationIfNeededWithCompletion:nil];
    [self setupBannerView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.dataSource.count == 0) {
        return;
    }

    // GDC is used to call becomeFirstResponder asynchronously to fix
    // a layout issue on iPad in landscape. Views presented as a UIModalPresentationFormSheet
    // and present a keyboard in viewDidAppear layout incorrectly
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->entryTextField becomeFirstResponder];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}


#pragma mark - Private Helpers

- (void)setupNavigationItem
{
    self.title = NSLocalizedString(@"Collaborators", @"Noun - collaborators are other Simplenote users who you chose to share a note with");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(onDone)];
}

- (void)setupContactsManager
{
    self.contactsManager = [SPContactsManager new];
}

- (void)setupTextFields
{
    entryTextField.placeholder = NSLocalizedString(@"Add a new collaborator...", @"Noun - collaborators are other Simplenote users who you chose to share a note with");
}

- (void)setupWithCollaborators:(NSArray *)collaborators
{
    NSMutableSet *merged = [NSMutableSet set];

    for (NSString *tag in collaborators) {
        NSArray *filtered = [self.contactsManager peopleWith:tag];
        if (filtered.count == 0) {
            PersonTag *person = [[PersonTag alloc] initWithName:nil email:tag];
            [merged addObject:person];
            continue;
        }

        [merged addObjectsFromArray:filtered];
    }

    self.dataSource = [[[merged allObjects] sortedArrayUsingSelector:@selector(compareName:)] mutableCopy];

    [primaryTableView reloadData];
}


#pragma mark UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:primaryTableView]) {
        return self.dataSource.count;
    }

    return [super tableView:tableView numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:primaryTableView]) {
        return self.dataSource.count > 0 ? NSLocalizedString(@"Current Collaborators", nil) : nil;
    }

    return [super tableView:tableView titleForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([tableView isEqual:primaryTableView]) {
        if (self.dataSource.count > 0) {
            return nil;
        } else {
            return NSLocalizedString(@"Add an email address to share this note with someone. Then you can both make changes to it.", @"Description text for the screen that allows users to share notes with other users");
        }
    }

    return [super tableView:tableView titleForFooterInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPEntryListCell *cell = (SPEntryListCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    PersonTag *personTag;

    if ([tableView isEqual:primaryTableView]) {
        personTag = self.dataSource[indexPath.row];
    } else {
        personTag = self.autoCompleteDataSource[indexPath.row];
    }
    
    BOOL hasName = personTag.name.length > 0;
    NSString *primaryText = hasName ? personTag.name : personTag.email;
    NSString *secondaryText = hasName ? personTag.email : nil;
    
    [cell setupWithPrimaryText:primaryText secondaryText:secondaryText checkmarked:personTag.active];
    
    return cell;
}

- (void)removeItemFromDataSourceAtIndexPath:(NSIndexPath *)indexPath
{
    PersonTag *person = self.dataSource[indexPath.row];

    [self.collaboratorDelegate collaboratorViewController:self didRemoveCollaborator:person.email];
    [super removeItemFromDataSourceAtIndexPath:indexPath];
}


#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    if ([tableView isEqual:primaryTableView]) {

        PersonTag *person = self.dataSource[indexPath.row];
        person.active = !person.active;
        
        if (person.active) {
            [self.collaboratorDelegate collaboratorViewController:self didAddCollaborator:person.email];
        } else {
            [self.collaboratorDelegate collaboratorViewController:self didRemoveCollaborator:person.email];
        }
        
        [tableView reloadData];
        
    } else if ([tableView isEqual:autoCompleteTableView]) {
        
        PersonTag *person = self.autoCompleteDataSource[indexPath.row];
        [self addPersonTag:person];
    }
}

- (void)addPersonTag:(PersonTag *)person
{
    // make sure email address is actually an email address
    person.email = [person.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![person.email isValidEmailAddress]) {
        return;
    }
    
    // check to see from delegate if should add collaborator
    if ([self.collaboratorDelegate collaboratorViewController:self shouldAddCollaborator:person.email]) {
        [self.collaboratorDelegate collaboratorViewController:self didAddCollaborator:person.email];
        
        person.active = YES;
        [self.dataSource addObject:person];
        
        entryTextField.text = @"";
        [primaryTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self updateAutoCompleteMatchesForString:nil];
    }
}

- (void)processTextInField
{
    NSString *email = entryTextField.text;
    if (email.isValidEmailAddress == false) {
        return;
    }

    NSArray *filtered = [self.contactsManager peopleWith:email];
    PersonTag *person = filtered.firstObject ?: [[PersonTag alloc] initWithName:nil email:email];

    [self addPersonTag:person];
}


- (void)updateAutoCompleteMatchesForString:(NSString *)string
{
    if (self.contactsManager.authorized == false) {
        return;
    }

    if (string.length > 0) {
        NSArray *peopleFiltered = [self.contactsManager peopleWith:string];
        NSSet *datasourceSet = [NSSet setWithArray:self.dataSource];
        NSMutableSet *peopleSet = [NSMutableSet setWithArray:peopleFiltered];
        [peopleSet minusSet:datasourceSet];

        self.autoCompleteDataSource = [peopleSet.allObjects sortedArrayUsingSelector:@selector(compareName:)];
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


#pragma mark CNContactPickerDelegate Conformance

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
{
    [self createPersonTagFromProperty:contactProperty];
}


#pragma mark - Helpers

- (void)createPersonTagFromProperty:(CNContactProperty *)property
{
    NSString *name = [CNContactFormatter stringFromContact:property.contact style:CNContactFormatterStyleFullName];
    NSString *email = property.value;

    if (email.length == 0) {
        return;
    }

    PersonTag *personTag = [[PersonTag alloc] initWithName:name email:email];
    [self addPersonTag:personTag];
}


#pragma mark - Action Helpers

- (void)entryFieldPlusButtonTapped:(id)sender {
    
    [self displayAddressPicker];
}

- (void)displayAddressPicker
{
    CNContactPickerViewController *pickerViewController = [CNContactPickerViewController new];
    pickerViewController.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"];
    pickerViewController.displayedPropertyKeys = @[CNContactEmailAddressesKey];
    pickerViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    pickerViewController.delegate = self;

    [self presentViewController:pickerViewController animated:YES completion:nil];
}

@end

## Testing
Note: (A) means Automated Test. If automated UI tests were executed for the app, there's no need to run tests marked with (A) manually.

### Setup 

- [ ] Sign up using mixed-capitalization in the email address. Use this account to run all tests below.

#### Login/Signup

- [ ] Welcome note is shown for newly signed-up user.
- [ ] Logout. (A)
- [ ] Login with wrong password fails. (A)
- [ ] Login with correct password succeeds. (A)

#### Sync

- [ ] Created note appears in other device.
- [ ] Changes to new note sync to/from other device.
- [ ] New tag immediately syncs to/from other device.
- [ ] Removed tag immediately syncs to/from other device.
- [ ] Note publishes with link.
- [ ] Note unpublishes.
- [ ] Note publish change syncs _from_ other device (visible with dialog open).
- [ ] Markdown setting syncs to/from other device.
- [ ] Preview mode disappears/reappears when receiving remote changes to markdown setting.
- [ ] Note pinning syncs immediately to/from other device.
- [ ] Note pinning works regardless if done from list view or note info.
- [ ] Viewing history on one device leaves note unchanged on other device.
- [ ] Restoring history immediately syncs note to/from other device.
- [ ] After disabling network connectivity and making changes, selecting Log Out triggers an `Unsynced Notes Detected` alert.
- [ ] After going back online, changes sync.

#### Note editor

- [ ] Can preview markdown by swiping. (A)
- [ ] Can flip to edit mode (from markdown preview) by swiping. (A)
- [ ] Using the Insert checklist item from the format menu inserts a checklist. (A)
- [ ] "Undo" undoes the last edit. (A)
- [ ] Typing `- [x]` creates a checked checklist item. (A)
- [ ] Typing `- [ ]` created an unchecked checklist item. (A)
- [ ] Typing `-`, `+`, or `*` creates a list. (A)
- [ ] All list bullet types render to markdown lists. (A)
- [ ] Added URL is linkified. (A)
- [ ] Long-tapping on link opens the link in new window (regular tap in preview). (A)

#### Tags & search

- [ ] Can filter by tag when clicking on tag in tag drawer. (A)
- [ ] Searching in the search field highlights matches in note list.
- [ ] Searching in the search field highlights matches in the note editor.
- [ ] Clearing the search field immediately updates filtered notes. (A)
- [ ] Clicking on different tags or All Notes or Trash immediately updates filtered notes. (A)
- [ ] Can search by keyword. (A)
- [ ] Tag auto-completes appear when typing in search field. (A)
- [ ] Typing `tag:` and something else, like `tag:te` results in autocomplete tag results including that something else, e.g. `test`. (A)
- [ ] Tag suggestions suggest tags regardless of case. (A)
- [ ] Search field updates with results of `tag:test` format search string. (A)

#### Trash

- [ ] Can view trashed notes by selecting `Trash`. (A)
- [ ] Can delete note forever from trash screen. (A)
- [ ] Can restore note from trash screen. (A)
- [ ] Can trash note. (A)

#### Settings

- [ ] Can change analytics sharing setting.
- [ ] Changing `Condensed Note List` mode immediately updates and reflects in note list. (A)
- [ ] Changing `Sort Order` immediately updates and reflects in note list.
- [ ] Changing `Tag Sorting` immediately updates and reflects in tag list.
- [ ] For each sort type the pinned notes appear first in the note list.
- [ ] Changing `Theme` immediately updates app for desired color scheme.
- [ ] After setting a passcode, passcode (or Touch/Face ID if also enabled) is required to resume the app.
- [ ] Can turn passcode lock off with correct 4-digit passcode (also disables Touch/Face ID).
#### Scroller
-[] Verify that scroller functionality is working fine in Desktop , iOS and Android Device

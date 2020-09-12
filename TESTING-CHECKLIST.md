## Testing

### Login

- [ ] Logout
- [ ] Login with wrong password fails
- [ ] Login with correct password succeeds

### Sync

- [ ] Create new note appears in other device
- [ ] Changes to new note sync to/from other device
- [ ] New tag immediately syncs to/from other device
- [ ] Removed tag immediately syncs to/from other device
- [ ] Note publishes with link
- [ ] Note unpublishes
- [ ] Note publish change syncs _from_ other device
- [ ] Markdown setting syncs to/from other device
- [ ] Preview mode disappears/reappears when receiving remote changes to markdown setting
- [ ] Note pinning syncs immediately to/from other device
- [ ] Note pinning works regardless if selecting in list view or from note info
- [ ] Restoring history immediately syncs note from both directions
- [ ] After disabling network connectivity and making changes, selecting Log Out triggers an `Unsynced Notes Detected` alert
- [ ] After going back online, changes sync

### Note editor

- [ ] Can preview markdown by swiping
- [ ] Can flip to edit mode (from markdown preview) by swiping
- [ ] Using the Insert checklist item from the format menu inserts a checklist
- [ ] "Undo" undoes the last edit
- [ ] Typing `- [x]` creates a checked checklist item
- [ ] Typing `- [ ]` created an unchecked checklist item
- [ ] Typing `-`, `+`, or `*` creates a list
- [ ] All list bullet types render to markdown lists
- [ ] Added URL is linkified
- [ ] Long-tapping on link opens the link in new window (regular tap in preview)

### Tags & search

- [ ] Can filter by tag when clicking on tag in tag drawer
- [ ] Searching in the search field highlights matches in note list
- [ ] Searching in the search field highlights matches in the note editor
- [ ] Clearing the search field immediately updates filtered notes
- [ ] Clicking on different tags or All Notes or Trash immediately updates filtered notes
- [ ] Can search by keyword
- [ ] Tag auto-completes appear when typing in search field
- [ ] Typing `tag:` and something else, like `tag:te` results in autocomplete tag results including that something else, e.g. `test`
- [ ] Tag suggestions suggest tags regardless of case
- [ ] Search field updates with results of `tag:test` format search string

### Trash

- [ ] Can view trashed notes by selecting `Trash`
- [ ] Can delete note forever from trash screen
- [ ] Can restore note from trash screen
- [ ] Can trash note

### Settings

- [ ] Can change analytics sharing setting
- [ ] Changing `Condensed Note List` mode immediately updates and reflects in note list
- [ ] For each sort type the pinned notes appear first in the note list
- [ ] Changing `Theme` immediately updates app for desired color scheme
- [ ] After setting a passcode, passcode (or Touch/Face ID if also enabled) is required to resume the app
- [ ] Can turn passcode lock off with correct 4-digit passcode (also disables Touch/Face ID)

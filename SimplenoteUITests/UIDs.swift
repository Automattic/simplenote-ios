enum UID {

    enum Picture {
        static let appLogo = "simplenote-logo"
    }

    enum Cell {
        static let settings = "settings"
    }

    enum NavBar {
        static let allNotes = "All Notes"
        static let logIn = "Log In"
        static let noteEditorPreview = "Preview"
        static let noteEditorOptions = "Options"
        static let trash = "Trash"
    }

    enum Button {
        static let newNote = "New note"
        static let done = "Done"
        static let edit = "Edit"
        static let back = "Back"
        static let accept = "Accept"
        static let yes = "Yes"
        static let menu = "menu"
        static let signUp = "Sign Up"
        static let logIn = "Log In"
        static let logInWithEmail = "Log in with email"
        static let allNotes = "All Notes"
        static let trash = "Trash"
        static let settingsLogOut = "Log Out"
        static let noteEditorAllNotes = "All Notes"
        static let noteEditorChecklist = "Inserts a new Checklist Item"
        static let noteEditorInformation = "Information"
        static let noteEditorMenu = "note-menu"
        static let itemTrash = "icon trash"
        static let trashNote = "Move to Trash"
        static let restoreNote = "Restore Note"
        static let dismissHistory = "Dismiss History"
        static let deleteNote = "Delete Note"

        // "Empty Trash" button label is generated
        // differently by Xcode 12.4 and 12.5 (runs iOS 14.5+)
        static private(set) var trashEmptyTrash: String = {
            if #available(iOS 14.5, *) {
                return "Empty trash"
            } else {
                return "Empty"
            }
        }()

        static let clearText = "Clear text"
        static let cancel = "Cancel"
        static let dismissKeyboard = "Dismiss keyboard"
        static let deleteTagConfirmation = "Delete Tag"
        static let select = "Select"
        static let selectAll = "Select All"
        static let deselectAll = "Deselect All"
        static let trashNotes = "Trash Notes"
        static let crossIcon = "icon cross"
        static let undoTrashButton = "Undo"
        static let copyInternalLink = "Copy Internal Link"
    }

    enum Text {
        static let noteEditorPreview = "Preview"
        static let noteEditorOptionsMarkdown = "Markdown"
        static let nodeEditorOptionsHistory = "History"
        static let allNotesInProgress = "In progress"
        static let searchByTag = "Search by Tag"
        static let notes = "Notes"
    }

    enum TextField {
        static let email = "Email"
        static let password = "Password"
        static let tag = "Tag..."
    }

    enum SearchField {
        static let search = "Search notes or tags"
    }

    enum ContextMenuItem {
        static let paste = "Paste"
    }
}

enum Text {
    static let appName = "Simplenote"
    static let appTagline = "The simplest way to keep notes."
    static let alertHeadingSorry = "Sorry!"
    static let alertContentLoginFailed = "Could not login with the provided email address and password."
    static let alertReviewAccount = "Review Your Account"
    static let loginEmailInvalid = "Your email address is not valid"
    static let loginPasswordShort = "Password must contain at least 4 characters"
}

let testDataEmail = "simplenoteuitest@mailinator.com"
let testDataPassword = "qazxswedc"

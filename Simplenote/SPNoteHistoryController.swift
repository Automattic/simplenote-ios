import Foundation

// MARK: - SPNoteHistoryController: Business logic for history view controller
//
final class SPNoteHistoryController {

    // MARK: - State of the screen
    //
    enum State {
        /// Version (is fully loaded)
        /// - Parameters
        ///     - versionNumber: version number
        ///     - date: formatted date of the version
        ///     - isRestorable: possibility to restore to this version
        ///
        case version(versionNumber: Int, date: String, isRestorable: Bool)

        /// Version (is being loaded)
        /// - Parameters
        ///     - versionNumber: version number
        ///
        case loadingVersion(versionNumber: Int)

        /// Error
        ///
        case error(String)
    }

    /// Observer sends changes of the state (to history view controller)
    /// When assigned, it sends current state
    ///
    var observer: ((State) -> Void)? {
        didSet {
            observer?(state)
        }
    }

    /// Range of versions available to load
    /// Contains at least the current version of an object
    ///
    let versionRange: ClosedRange<Int>

    /// Delegate
    ///
    weak var delegate: SPNoteHistoryControllerDelegate?

    private let note: Note
    private let versionsController: VersionsController
    private var versionsToken: Any?
    private var state: State {
        didSet {
            observer?(state)
        }
    }
    private var versions: [Int: SPHistoryVersion] = [:]

    /// Designated initializer
    ///
    /// - Parameters:
    ///     - note: Note
    ///     - loader: History loader for specified Note
    ///
    init(note: Note, versionsController: VersionsController) {
        self.note = note
        self.versionsController = versionsController

        versionRange = VersionsController.range(forCurrentVersion: note.versionInt)
        state = .loadingVersion(versionNumber: versionRange.upperBound)
    }

    convenience init(note: Note) {
        self.init(note: note, versionsController: SPAppDelegate.shared().versionsController)
    }
}

// MARK: - Communications from UI
//
extension SPNoteHistoryController {

    /// User tapped on close button
    ///
    func handleTapOnCloseButton() {
        delegate?.noteHistoryControllerDidCancel()
    }

    /// User tapped on restore button
    ///
    func handleTapOnRestoreButton() {
        delegate?.noteHistoryControllerDidFinish()
    }

    /// User selected a version
    ///
    func select(versionNumber: Int) {
        switchToVersion(versionNumber)
    }

    /// Invoked when view is loaded
    ///
    func onViewLoad() {
        guard SPAppDelegate.shared().simperium.authenticator.connected else {
            state = .error(Localization.networkError)
            return
        }

        loadData()
    }
}

// MARK: - Private Methods
//
private extension SPNoteHistoryController {
    func loadData() {
        versionsToken = versionsController.requestVersions(for: note.simperiumKey, currentVersion: note.versionInt) { [weak self] (version) in
            self?.process(noteVersion: version)
        }
    }

    func process(noteVersion: SPHistoryVersion) {
        versions[noteVersion.version] = noteVersion

        // We received a note version with the same version as currently showing
        // Update state using new information
        if state.versionNumber == noteVersion.version {
            switchToVersion(noteVersion.version)
        }
    }

    func switchToVersion(_ versionNumber: Int) {
        if let noteVersion = versions[versionNumber] {
            state = .version(versionNumber: versionNumber,
                             date: note.dateString(noteVersion.modificationDate, brief: false),
                             isRestorable: noteVersion.version != note.versionInt)
            delegate?.noteHistoryControllerDidSelectVersion(withContent: noteVersion.content)
        } else {
            state = .loadingVersion(versionNumber: versionNumber)
        }
    }
}

// MARK: - State extension
//
private extension SPNoteHistoryController.State {
    var versionNumber: Int? {
        switch self {
        case .version(let versionNumber, _, _), .loadingVersion(let versionNumber):
            return versionNumber
        case .error:
            return nil
        }
    }
}

// MARK: - Localization
//
private struct Localization {
    static let networkError = NSLocalizedString("Couldn't Retrieve History", comment: "Error message shown when trying to view history of a note without an internet connection")
}

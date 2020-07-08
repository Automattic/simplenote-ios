import Foundation

// MARK: - SPNoteHistoryController: Business logic for history view controller
//
final class SPNoteHistoryController {

    // MARK: - Presentable: history item representation for a view
    //
    struct Presentable {
        let date: String
        let isRestorable: Bool
    }

    // MARK: - State of the screen
    //
    enum State {
        /// Loading data
        ///
        case loading

        /// Ready to show results
        ///
        case results([Presentable])

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

    /// Delegate
    ///
    weak var delegate: SPNoteHistoryControllerDelegate?

    private let note: Note
    private let loader: SPHistoryLoader
    private var historyItems: [SPHistoryLoader.Item] = [] {
        didSet {
            let presentables = historyItems.map { presentable(from: $0) }
            state = .results(presentables)
        }
    }

    private var state: State = .loading {
        didSet {
            observer?(state)
        }
    }

    /// Designated initializer
    ///
    /// - Parameters:
    ///     - note: Note
    ///     - loader: History loader for specified Note
    ///
    init(note: Note, loader: SPHistoryLoader) {
        self.note = note
        self.loader = loader
    }
}

// MARK: - Input from UI
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
    func selectVersion(atIndex index: Int) {
        let item = historyItems[index]
        delegate?.noteHistoryControllerDidSelectVersion(with: item.content)
    }

    /// Invoked when view is loaded
    ///
    func onViewLoad() {
        guard SPAppDelegate.shared().simperium.authenticator.connected else {
            state = .error(NSLocalizedString("version-alert-message", comment: "Error alert message shown when trying to view history of a note without an internet connection"))
            return
        }

        loadData()
    }
}

// MARK: - Private Methods
//
private extension SPNoteHistoryController {
    func loadData() {
        state = .loading
        loader.load { [weak self] (items) in
            self?.historyItems = items
        }
    }

    func presentable(from historyItem: SPHistoryLoader.Item) -> Presentable {
        let noteVersion = Int(note.version() ?? "1") ?? 1
        return Presentable(date: note.dateString(historyItem.modificationDate, brief: false),
                           isRestorable: noteVersion != historyItem.version)
    }
}

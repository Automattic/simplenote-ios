import Foundation

final class SPNoteHistoryController {
    struct Presentable {
        let date: String
        let isRestorable: Bool
    }

    enum State {
        case loading
        case results([Presentable])
        case error(String)
    }

    enum Event {
        case dismiss
        case preview
        case restore
    }

    var observer: ((State) -> Void)? {
        didSet {
            observer?(state)
        }
    }
    var delegate: ((Event) -> Void)?

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

    init(note: Note, loader: SPHistoryLoader) {
        self.note = note
        self.loader = loader
    }
}

extension SPNoteHistoryController {
    func handleTapOnCloseButton() {
        delegate?(.dismiss)
    }

    func handleTapOnRestoreButton() {
        delegate?(.restore)
    }

    func selectVersion(atIndex index: Int) {
        delegate?(.preview)
    }

    func onViewLoad() {
        guard SPAppDelegate.shared().simperium.authenticator.connected else {
            state = .error(NSLocalizedString("version-alert-message", comment: "Error alert message shown when trying to view history of a note without an internet connection"))
            return
        }

        loadData()
    }
}

private extension SPNoteHistoryController {
    func loadData() {
        state = .loading
        loader.load { [weak self] (items) in
            self?.historyItems = items
        }
    }

    func presentable(from historyItem: SPHistoryLoader.Item) -> Presentable {
        let timeInterval = historyItem.data["modificationDate"] as? TimeInterval
        let date = Date(timeIntervalSince1970: timeInterval ?? 0)
        let noteVersion = Int(note.version() ?? "1") ?? 1

        return Presentable(date: note.dateString(date, brief: false),
                           isRestorable: noteVersion != historyItem.version)
    }
}

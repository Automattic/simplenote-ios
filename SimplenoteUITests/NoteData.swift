/// Value-type to describe the elements that represent a not as seen from the UI.
struct NoteData {
    let name: String
    let content: String
    private(set) var tags: [String] = []

    var formattedForAutomatedInput: String { "\(name)\n\n\(content)" }
}

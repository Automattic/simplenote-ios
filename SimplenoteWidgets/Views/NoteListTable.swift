import SwiftUI

struct NoteListTable: View {
    let entry: ListWidgetEntry
    let numberOfRows: Int
    let geometry: GeometryProxy

    var body: some View {
        let width = geometry.size.width - Constants.sidePadding
        let height = (geometry.size.height - Constants.headerSize) / CGFloat(numberOfRows)
        let entryCount = entry.noteProxys.count

        ForEach(.zero ..< entryCount) { index in
            let proxy = entry.noteProxys[index]
            Link(destination: proxy.url) {
                NoteListRow(noteTitle: proxy.title, width: width, height: height)
            }
        }

        if entryCount < numberOfRows {
            let remainder = numberOfRows - entryCount
            ForEach(.zero ..< remainder) { index in
                NoteListRow(noteTitle: "", width: width, height: height)
            }
        }
    }
}

private struct Constants {
    static let sidePadding = CGFloat(20)
    static let headerSize = CGFloat(45)
}

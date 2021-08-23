import SwiftUI

struct NoteListTable: View {
    let entry: ListWidgetEntry
    let numberOfRows: Int
    let geometry: GeometryProxy

    var body: some View {
        let width = geometry.size.width - Constants.sidePadding
        let height = (geometry.size.height - Constants.headerSize) / CGFloat(numberOfRows)
        let proxies = entry.noteProxys

        ForEach(.zero ..< numberOfRows) { index in
            let isLastRow = index == (numberOfRows - 1)

            if proxies.indices.contains(index) {
                let proxy = proxies[index]
                Link(destination: proxy.url) {
                    NoteListRow(noteTitle: proxy.title, width: width, height: height, lastRow: isLastRow)
                }
            } else {
                NoteListRow(noteTitle: "", width: width, height: height, lastRow: isLastRow)
            }
        }
    }
}

private struct Constants {
    static let sidePadding = CGFloat(20)
    static let headerSize = CGFloat(46)
}

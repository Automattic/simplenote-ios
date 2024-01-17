import SwiftUI

struct NoteListTable: View {
    let rows: [Row]
    let geometry: GeometryProxy

    var body: some View {
        let width = geometry.size.width - Constants.sidePadding
        let height = round((geometry.size.height - Constants.headerSize) / CGFloat(rows.count))

        ForEach(.zero ..< rows.count, id: \.self) { index in
            let isLastRow = index == (rows.count - 1)
            let row = rows[index]

            switch row {
            case .note(let proxy):
                Link(destination: proxy.url) {
                    NoteListRow(noteTitle: proxy.title, width: width, height: height, lastRow: isLastRow)
                }
            case .empty:
                NoteListRow(noteTitle: "", width: width, height: height, lastRow: isLastRow)
            }
        }
    }
}

private struct Constants {
    static let sidePadding = CGFloat(20)
    static let headerSize = CGFloat(46)
}

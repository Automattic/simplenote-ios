import Foundation
import UIKit


// MARK: - SPTagTableViewCell
//
@objcMembers
class SPTagTableViewCell: UITableViewCell {

    /// Note's Title
    ///
    var titleText: String? {
        get {
            textLabel?.text
        }
        set {
            textLabel?.text = newValue
        }
    }


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        refreshStyle()
    }
}


private extension SPTagTableViewCell {

    /// Refreshes the current Style current style
    ///
    func refreshStyle() {
        textLabel?.textColor = Style.textColor
        backgroundColor = Style.backgroundColor

        let selectedView = UIView(frame: bounds)
        selectedView.backgroundColor = Style.selectionColor
        selectedBackgroundView = selectedView
    }
}


// MARK: - SPTagTableViewCell
//
extension SPTagTableViewCell {

    /// Returns the Height that the receiver would require to be rendered
    ///
    /// Note: Why these calculations? why not Autosizing cells?. Well... Performance.
    ///
    static var cellHeight: CGFloat {
        let lineHeight = UIFont.preferredFont(forTextStyle: .headline).lineHeight
        let padding = Style.padding
        let result = padding.top + lineHeight + padding.bottom

        return result.rounded(.up)
    }
}


// MARK: - Cell Styles
//
private enum Style {

    /// Tag(s) Cell Vertical Padding
    ///
    static let padding = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)

    /// Returns the Cell's Background Color
    ///
    static var backgroundColor: UIColor {
        .simplenoteBackgroundColor
    }

    /// Headline Color: To be applied over the first preview line
    ///
    static var textColor: UIColor {
        .simplenoteNoteHeadlineColor
    }

    /// Color to be applied over the cell upon selection
    ///
    static var selectionColor: UIColor {
        .simplenoteLightBlueColor
    }
}

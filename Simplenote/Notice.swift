import Foundation

struct Notice {

    let message: String
    let action: NoticeAction?
    let isDismissible: Bool

    var hasAction: Bool {
        return action != nil
    }
}

extension Notice: Equatable {
    static func == (lhs: Notice, rhs: Notice) -> Bool {
        return lhs.message == rhs.message
    }
}

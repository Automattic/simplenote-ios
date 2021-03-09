import Foundation

struct Notice {
    // TODO: needs to be equatable

    let message: String
    let action: NoticeAction?

    var hasAction: Bool {
        return action != nil
    }
}

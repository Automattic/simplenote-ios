import Foundation

extension Note {
    var publishState: PublishState {
        if published && !publishURL.isEmpty {
            return .published
        }

        return .unpublished
    }
}

enum PublishState {
    case published
    case unpublished
}

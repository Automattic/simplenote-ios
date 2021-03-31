import Foundation

extension Note {
    var publishState: PublishState {
        if published && !publishURL.isEmpty {
            return .published
        }

        if published && publishURL.isEmpty {
            return .publishing
        }

        if !published && !publishURL.isEmpty {
            return .unpublishing
        }

        return .unpublished
    }
}

enum PublishState {
    case published
    case publishing
    case unpublished
    case unpublishing
}

import Foundation

extension Note {
    var publishState: PublishState {
        if published && publishURL != nil {
            return .published
        }

        return .unpublished

    }
}

import Foundation

extension ProcessInfo {
    var environmentIsPreview: Bool {
        environment[Constants.environmentXcodePreviewsKey] != Constants.isPreviews
    }
}

private struct Constants {
    static let environmentXcodePreviewsKey = "XCODE_RUNNING_FOR_PREVIEWS"
    static let isPreviews = "1"
}

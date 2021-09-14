import Foundation

enum BuildConfiguration: String {
    case debug
    case `internal`
    case appStore
    case release
    case unknown

    static var current: BuildConfiguration {

        #if DEBUG
            return .debug
        #elseif BUILD_INTERNAL
            return .internal
        #elseif BUILD_APP_STORE
            return .appStore
        #elseif BUILD_RELEASE
            return .release
        #else

            return .unknown
        #endif
    }

    static func `is`(_ configuration: BuildConfiguration) -> Bool {
        return configuration == current
    }
}

extension BuildConfiguration: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
}

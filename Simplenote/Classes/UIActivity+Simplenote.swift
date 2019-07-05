import Foundation


// MARK: - UIActivity <> WordPress iOS!
//
extension UIActivity.ActivityType {

    /// WordPress Share Extension (AppStore)
    ///
    static var wordPressShareAppStore: UIActivity.ActivityType {
        return UIActivity.ActivityType("org.wordpress.WordPressShare")
    }

    /// WordPress Share Extension (Internal Beta)
    ///
    static var wordPressShareInternal: UIActivity.ActivityType {
        return UIActivity.ActivityType("org.wordpress.internal.WordPressShare")
    }

    /// Indicates if a given UIActivity belongs to the WordPress iOS App
    ///
    var isWordPressActivity: Bool {
        let wordpressActivities: [UIActivity.ActivityType] = [
            .wordPressShareAppStore,
            .wordPressShareInternal
        ]

        return wordpressActivities.contains(self)
    }
}

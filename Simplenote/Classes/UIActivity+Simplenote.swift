import Foundation

// MARK: - UIActivity <> WordPress iOS!
//
extension UIActivity.ActivityType {

    /// WordPress Draft Extension (AppStore)
    ///
    static var wordPressDraftAppStore: UIActivity.ActivityType {
        return UIActivity.ActivityType("org.wordpress.WordPressDraftAction")
    }

    /// WordPress Draft Extension (Internal Beta)
    ///
    static var wordPressDraftInternal: UIActivity.ActivityType {
        return UIActivity.ActivityType("org.wordpress.internal.WordPressDraftAction")
    }

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
            .wordPressDraftAppStore,
            .wordPressDraftInternal,
            .wordPressShareAppStore,
            .wordPressShareInternal
        ]

        return wordpressActivities.contains(self)
    }
}

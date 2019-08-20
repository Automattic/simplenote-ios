import XCTest
@testable import Simplenote


// MARK: - SPCredentials Unit Tests
//
class SPCredentialsTests: XCTestCase {

    /// Verifies that the new Credentials mechanism match the legacy values
    ///
    func testCredentialsMatchTheirLegacyCredentialsCounterpart() {
        XCTAssertEqual(SPCredentials.appbotKey, SPLegacyCredentials.appbotKey())
        XCTAssertEqual(SPCredentials.bitHockeyIdentifier, SPLegacyCredentials.bitHockeyIdentifier())
        XCTAssertEqual(SPCredentials.googleAnalyticsID, SPLegacyCredentials.googleAnalyticsID())
        XCTAssertEqual(SPCredentials.iTunesAppID, SPLegacyCredentials.iTunesAppId())
        XCTAssertEqual(SPCredentials.iTunesReviewURL, SPLegacyCredentials.iTunesReviewURL())
        XCTAssertEqual(SPCredentials.sentryDSN, SPLegacyCredentials.simplenoteSentryDSN())
        XCTAssertEqual(SPCredentials.simperiumAppID, SPLegacyCredentials.simperiumAppID())
        XCTAssertEqual(SPCredentials.simperiumApiKey, SPLegacyCredentials.simperiumApiKey())
        XCTAssertEqual(SPCredentials.simperiumPreferencesObjectKey, SPLegacyCredentials.simperiumPreferencesObjectKey())
        XCTAssertEqual(SPCredentials.simperiumSettingsObjectKey, SPLegacyCredentials.simperiumSettingsObjectKey())
        XCTAssertEqual(SPCredentials.wpcomClientID, SPLegacyCredentials.WPCCClientID())
        XCTAssertEqual(SPCredentials.wpcomRedirectURL, SPLegacyCredentials.WPCCRedirectURL())
    }
}

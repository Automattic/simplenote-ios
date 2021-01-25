import XCTest
@testable import Simplenote

// MARK: - PinLockBaseControllerTests
//
class PinLockBaseControllerTests: XCTestCase {
    private let controller = PinLockBaseController()
    private let configurationObserver = PinLockControllerConfigurationObserver()

    func testSettingAnObserverWillImmediatelyCallItWithCurrentConfiguration() {
        // Given
        let configuration = PinLockControllerConfiguration.random()

        // When
        controller.configuration = configuration
        controller.configurationObserver = configurationObserver.handler

        // Then
        XCTAssertEqual(configurationObserver.configurations, [configuration])
        XCTAssertEqual(configurationObserver.animations, [nil])
    }

    func testSwitchToConfigurationCallsObserver() {
        // Given
        let configuration = PinLockControllerConfiguration.random()
        let animation = UIView.ReloadAnimation.slideLeading

        // When
        controller.configurationObserver = configurationObserver.handler
        controller.switchTo(configuration, with: animation)

        // Then
        XCTAssertEqual(configurationObserver.lastConfiguration, configuration)
        XCTAssertEqual(configurationObserver.lastAnimation, animation)
    }
}

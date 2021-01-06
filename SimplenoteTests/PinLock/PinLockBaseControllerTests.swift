import XCTest
@testable import Simplenote

// MARK: - PinLockBaseControllerTests
//
class PinLockBaseControllerTests: XCTestCase {
    private let controller = PinLockBaseController()

    func testSettingAnObserverWillImmediatelyCallItWithCurrentConfiguration() {
        // Given
        let configuration = PinLockControllerConfiguration.random()

        // When
        var actualConfiguration: PinLockControllerConfiguration?
        var actualAnimation: UIView.ReloadAnimation?

        controller.configuration = configuration
        controller.configurationObserver = { (configuration, animation) in
            actualConfiguration = configuration
            actualAnimation = animation
        }

        // Then
        XCTAssertEqual(actualConfiguration, configuration)
        XCTAssertNil(actualAnimation)
    }

    func testSwitchToConfigurationCallsObserver() {
        // Given
        let configuration = PinLockControllerConfiguration.random()
        let animation = UIView.ReloadAnimation.slideLeading

        // When
        var actualConfiguration: PinLockControllerConfiguration?
        var actualAnimation: UIView.ReloadAnimation?

        controller.configurationObserver = { (configuration, animation) in
            actualConfiguration = configuration
            actualAnimation = animation
        }

        controller.switchTo(configuration, with: animation)

        // Then
        XCTAssertEqual(actualConfiguration, configuration)
        XCTAssertEqual(actualAnimation, animation)
    }
}

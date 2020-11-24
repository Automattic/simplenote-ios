import Foundation
import QuartzCore

// MARK: - ViewSpinner: Spin a view
//
final class ViewSpinner {
    private let view: UIView
    private var displayLink: CADisplayLink?

    private var angle: Double = 0.0
    private var velocity: Double = 0.0

    /// Callback is invoked once max velocity is reached
    ///
    var onMaxVelocity: (() -> Void)?

    /// Init with a view to spin
    ///
    init(view: UIView) {
        self.view = view
    }

    /// Start spinning
    ///
    func start() {
        guard displayLink == nil else {
            return
        }

        view.layer.removeAllAnimations()
        velocity = 0.0
        angle = 0.0

        displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
        displayLink?.add(to: .current, forMode: .common)
    }

    /// Stop spinning
    ///
    func stop() {
        guard displayLink != nil else {
            return
        }

        displayLink?.invalidate()
        displayLink = nil

        let doublePi = 2 * Double.pi
        let targetAngle = ceil(angle / doublePi) * doublePi + doublePi

        view.layer.setAffineTransform(.init(rotationAngle: -CGFloat(targetAngle)))
        let spring = CASpringAnimation(keyPath: "transform.rotation")
        spring.damping = Constants.decelertaionDamping
        spring.initialVelocity = CGFloat((targetAngle - angle) / velocity)
        spring.fromValue = -angle
        spring.toValue = -targetAngle
        spring.duration = Constants.decelerationDuration
        spring.isRemovedOnCompletion = true
        view.layer.add(spring, forKey: "rotation")
    }

    @objc
    private func update(_ displayLink: CADisplayLink) {
        let timeDelta = displayLink.targetTimestamp - displayLink.timestamp

        let prevVelocity = velocity
        velocity = velocity + Constants.acceleration * timeDelta
        velocity = min(velocity, Constants.maxVelocity)

        angle = angle + velocity * timeDelta
        view.transform = .init(rotationAngle: -CGFloat(angle))

        let shouldNotifyAboutMaxVelocity = prevVelocity < Constants.maxVelocity && velocity == Constants.maxVelocity
        if shouldNotifyAboutMaxVelocity {
            onMaxVelocity?()
        }
    }
}

// MARK: - Constants
//
private enum Constants {
    static let acceleration = Double(40.0) // Radians per sec
    static let maxVelocity = Double(50.0) // Radians per sec

    static let decelerationDuration = TimeInterval(1.5)
    static let decelertaionDamping = CGFloat(14.0)
}

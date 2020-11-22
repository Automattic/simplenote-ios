import Foundation
import QuartzCore

final class ViewSpinner {
    private let view: UIView
    private var displayLink: CADisplayLink?
    private var angle: CGFloat = 0.0

    private var velocity: Double = 0.0
    private var acceleration: Double = 65.0

    init(view: UIView) {
        self.view = view

        view.isUserInteractionEnabled = true

        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleGestureRecognizer(_:)))
        gestureRecognizer.minimumPressDuration = 0.5
        view.addGestureRecognizer(gestureRecognizer)
    }

    @objc
    private func handleGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            start()
        case .ended, .cancelled, .failed:
            stop()
        case .possible, .changed:
            break
        @unknown default:
            break
        }
    }

    private func start() {
        guard displayLink == nil else {
            view.layer.removeAllAnimations()
            return
        }

        view.layer.removeAllAnimations()
        velocity = 0.0
        angle = 0.0

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .common)
    }

    private func stop() {
        guard displayLink != nil else {
            return
        }

        displayLink?.invalidate()
        displayLink = nil

        let time = Double(1)
        let distance = ceil(Double(angle) / (2 * Double.pi)) * (2 * Double.pi) + (2 * Double.pi)

        view.layer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(distance)))
        let spring = CASpringAnimation(keyPath: "transform.rotation")
        spring.damping = 15.0
        spring.initialVelocity = CGFloat((distance - Double(angle)) / velocity)
        spring.fromValue = -angle
        spring.toValue = -distance
        spring.duration = time
        spring.isRemovedOnCompletion = true
        view.layer.add(spring, forKey: "rotation")
    }

    @objc
    private func update() {
        guard let displayLink = displayLink else {
            return
        }

        let delta = displayLink.targetTimestamp - displayLink.timestamp

        velocity = velocity + acceleration * delta
        velocity = min(velocity, 40)

        angle = CGFloat(Double(angle) + velocity * delta)

        view.transform = .init(rotationAngle: -angle)
    }
}

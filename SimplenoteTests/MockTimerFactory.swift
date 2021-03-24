@testable import Simplenote

class MockTimerFactory: TimerFactory {
    var timer: MockTimer?

    override func scheduledTimer(with timeInterval: TimeInterval, completion: @escaping () -> Void) -> Timer {
        let timer = MockTimer()
        self.timer = timer
        timer.completion = completion
        return timer
    }
}

class MockTimer: Timer {
    var completion: (() -> Void)?

    convenience init(completion: (() -> Void)? = nil) {
        self.init()
        self.completion = completion
    }

    override func fire() {
        completion?()
    }

    override func invalidate() {
        completion = nil
    }
}

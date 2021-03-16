import Foundation

class TimerFactory {
    func scheduledTimer(with timeInterval: TimeInterval, completion: @escaping () -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { (_) in
            completion()
        }
    }
}

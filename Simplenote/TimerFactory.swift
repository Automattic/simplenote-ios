import Foundation

class TimerFactory {
    func scheduledTimer(with timeInterval: TimeInterval, completion: @escaping () -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { (_) in
            completion()
        }
    }

    func repeatingTimer(with timerInterval: TimeInterval, completion: @escaping (Timer)-> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { (timer) in
            completion(timer)
        }
    }
}

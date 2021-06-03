import Foundation
import BackgroundTasks

class BackgroundRefreshManager: NSObject {
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private var handler: (()->Void)?

    private func refreshTimer() {
        // If refresh is not running there will be no handler
        guard handler != nil else {
            return
        }
        NSLog("Refresh Timer Called")
        timer = Timer.scheduledTimer(timeInterval: Constants.timerTimeOut, target: self, selector: #selector(finishRefresh), userInfo: nil, repeats: false)
    }

    @objc
    private func finishRefresh() {
        guard let handler = handler else {
            return
        }
        NSLog("Finish Refresh Called")

        handler()

        self.handler = nil
        self.timer = nil
    }

    @objc
    func onSimperiumChange() {
        refreshTimer()
    }
}

@available(iOS 13.0, *)
extension BackgroundRefreshManager {
    // MARK: - Background Fetch
    //
    @objc
    func registerBackgroundRefreshTask() {
        NSLog("Registered background task with identifier \(Constants.bgTaskIdentifier)")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.bgTaskIdentifier, using: .main) { task in
            guard let task = task as? BGAppRefreshTask else {
                return
            }
            self.handleAppRefresh(task: task)
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        NSLog("Did fire handle app refresh")
        handler = {
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = { [weak self] in
            self?.finishRefresh()
        }

        NSLog("Background refresh intiated")
        scheduleAppRefresh()

        refreshTimer()
    }

    @objc
    func scheduleAppRefresh() {
        guard BuildConfiguration.current == .debug else {
            return
        }

        NSLog("Background refresh scheduled")
        let request = BGAppRefreshTaskRequest(identifier: Constants.bgTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: Constants.earliestBeginDate)
        do {
            try BGTaskScheduler.shared.submit(request)
            NSLog("Background refresh submitted")
        } catch {
            print("Couldn't schedule app refersh: \(error)")
        }
    }

    @objc
    func cancelPendingRefreshTasks() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: Constants.bgTaskIdentifier)
    }
}


private struct Constants {
    static let earliestBeginDate = TimeInterval(60) //30 minutes
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.codality.NotationalFlow"
    static let bgTaskIdentifier = bundleIdentifier + ".refresh"
    static let timerTimeOut = TimeInterval(8)
}

import Foundation
import BackgroundTasks


class SPBackgroundRefresh: NSObject {
}

@available(iOS 13.0, *)
extension SPBackgroundRefresh {
    // MARK: - Background Fetch
    //
    @objc
    func registerBackgroundRefreshTask() {
        guard BuildConfiguration.current == .debug else {
            return
        }

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
        guard BuildConfiguration.current == .debug else {
            return
        }

        NSLog("Background refresh intiated")
        scheduleAppRefresh()

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.timeOut) {
            NSLog("Background refresh finishing")
            task.setTaskCompleted(success: true)
        }
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
        } catch {
            print("Couldn't schedule app refersh: \(error)")
        }
    }
}


private struct Constants {
    static let earliestBeginDate = TimeInterval(60) //30 minutes
    static let timeOut = TimeInterval(25)
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.codality.NotationalFlow"
    static let bgTaskIdentifier = bundleIdentifier + ".refresh"
    static let timerTimeOut = TimeInterval(5)
}

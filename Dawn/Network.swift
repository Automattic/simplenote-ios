//
//  Network.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation



// MARK: - NetworkDelegate
//
protocol NetworkDelegate: AnyObject {
    func network(_ network: Network, didBecomeInvalidWithError error: Error?)
}


// MARK: - Network
//
class Network: NSObject {

    /// Internal URLSession reference
    ///
    private var session: URLSession!

    /// Network Delegate
    ///
    weak var delegate: NetworkDelegate?


    deinit {
        finishTasksAndInvalidate()
    }

    /// Designated Initializer
    ///
    override init() {
        super.init()
        session = URLSession(configuration: .dawnConfiguration(), delegate: self, delegateQueue: nil)
    }
}


// MARK: - Internal API(s)
//
extension Network {

    /// Retrieves the contents of the specified URL.
    ///
    func perform(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }

    /// Retrieves the contents of the specified URL, in a Swift Async fashion
    ///
    func perform(request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }

    /// Downloads the contents at the specified URL, saves the results to a file, and invokes the Completion Handler
    ///
    func downloadToFile(request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) {
        let task = session.downloadTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}


// MARK: - Invalidation
//
extension Network {

    /// Invalidates the session, allowing any outstanding tasks to finish.
    /// - Important: After invalidation, `DONetwork` cannot be reused
    ///
    func finishTasksAndInvalidate() {
        session.finishTasksAndInvalidate()
    }

    /// Cancels all outstanding tasks and then invalidates the session.
    /// - Important: After invalidation, `DONetwork` cannot be reused
    ///
    func invalidateAndCancel() {
        session.invalidateAndCancel()
    }
}


// MARK: - URLSession Delegate Methods
//
extension Network: URLSessionDelegate {

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        delegate?.network(self, didBecomeInvalidWithError: error)
    }
}

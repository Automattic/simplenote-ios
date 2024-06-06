//
//  LoginRemote.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 6/6/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Foundation

// MARK: - SignupRemote
//
class LoginRemote: Remote {

    func requestLoginEmail(with email: String, completion: @escaping (_ result: Result<Data?, RemoteError>) -> Void) {
        let urlRequest = request(with: email)

        performDataTask(with: urlRequest, completion: completion)
    }

    private func request(with email: String) -> URLRequest {
        let url = URL(string: SimplenoteConstants.loginURL)!

        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: RemoteConstants.timeout)

        request.httpMethod = RemoteConstants.Method.POST
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["username": email.lowercased()])

        return request
    }
}

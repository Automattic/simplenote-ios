//
//  NetworkRequest.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


// MARK: - HTTPMethod
//
public enum HTTPMethod: String, CaseIterable {
    case delete     = "DELETE"
    case get        = "GET"
    case head       = "HEAD"
    case post       = "POST"
    case put        = "PUT"
}

private extension HTTPMethod {

    var encodesParametersInBody: Bool {
        self == .post || self == .put
    }

    var encodesParametersInURL: Bool {
        self == .get || self == .head || self == .delete
    }
}


// MARK: - NetworkRequest
//
public struct NetworkRequest {

    /// Our Backend's Base URL
    ///
    let baseURL: URL

    /// Target Endpoint's Path
    ///
    let path: String

    /// Request Parameters
    ///
    let parameters: [String: Any]?

    /// HTTP Method we should invoke
    ///
    let method: HTTPMethod

    /// HTTP Headers we should inject
    ///
    let extraHTTPHeaders: [String: String]?

    /// Request Body: When set, this property overrides the httpBody as specified
    ///
    let explicitEncodedBody: Data?

    /// Request Timeout, in seconds
    ///
    let timeoutInterval: TimeInterval?


    // MARK: - Designated Initializer

    public init(baseURL: URL, path: String, parameters: [String: Any]?, method: HTTPMethod, extraHTTPHeaders: [String: String]?, explicitEncodedBody: Data?, timeoutInterval: TimeInterval?) {
        self.baseURL =  baseURL
        self.path = path
        self.parameters = parameters
        self.method = method
        self.extraHTTPHeaders = extraHTTPHeaders
        self.explicitEncodedBody = explicitEncodedBody
        self.timeoutInterval = timeoutInterval
    }


    /// Encodes the receiver as a URLRequest
    ///
    public func asURLRequest() -> URLRequest {
        var request = URLRequest(url: encodeRequestURL())

        request.httpMethod = method.rawValue
        request.httpBody = explicitEncodedBody ?? encodeRequestBody()
        request.setValue(defaultContentType(), forHTTPHeaderField: "Content-Type")

        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }

        guard let headers = extraHTTPHeaders else {
            return request
        }

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}


// MARK: - Private API(s)
//
private extension NetworkRequest {

    func encodeRequestBody() -> Data? {
        guard method.encodesParametersInBody, let parameters = parameters else {
            return nil
        }

        return try! JSONSerialization.data(withJSONObject: parameters)
    }

    func encodeRequestURL() -> URL {
        let url = URL(string: path, relativeTo: baseURL)!
        guard method.encodesParametersInURL, let parameters = parameters else {
            return url
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.setQueryItems(with: parameters)

        return components.url!
    }

    func defaultContentType() -> String? {
        guard method.encodesParametersInBody else {
            return nil
        }

        return "application/json; charset=utf-8"
    }
}

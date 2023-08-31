//
//  DawnRemote
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


class DawnRemote {

    let network = Network()
}


extension DawnRemote {

    /// Runs the specified URLRequest and parses the specified Decodable Type
    ///
    func runRequest<T: Decodable>(_ request: URLRequest, type: T.Type, decoder: JSONDecoder = .mercuryRecordDecoder, handler: @escaping (Swift.Result<T, Error>) -> Void) {
        let parser = CodableResponseParser(type: type, decoder: decoder)
        runRequest(request, parser: parser, completion: handler)
    }

    /// Runs the specified URLRequest, and attempts to parse its Response with the specified DOResponseParser instance
    ///
    func runRequest<Parser: ResponseParser>(_ request: URLRequest, parser: Parser, completion: @escaping (Swift.Result<Parser.Output, Error>) -> Void) {
        network.perform(request: request) { (responseData, response, responseError) in
            do {
                let result = try parser.parse(request: request, responseData: responseData, response: response, error: responseError)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Runs the specified URLRequest, and attempts to parse its Response with the specified DOResponseParser instance
    ///
    @discardableResult
    func runRequest<Parser: ResponseParser>(_ request: URLRequest, parser: Parser) async throws -> Parser.Output {
        let (data, response) = try await network.perform(request: request)
        return try parser.parse(request: request, responseData: data, response: response, error: nil)
    }
}

extension DawnRemote {

    func request(method: HTTPMethod, path: String, parameters: [String: Any]? = nil, extraHTTPHeaders: [String: String]? = nil, explicitEncodedBody: Data? = nil, timeout: TimeInterval? = nil) -> URLRequest {
        var headers = extraHTTPHeaders ?? [String: String]()
        headers["Authorization"] = DawnConstants.authToken

        let request = NetworkRequest(baseURL: DawnConstants.baseURL,
                                     path: path,
                                     parameters: parameters,
                                     method: method,
                                     extraHTTPHeaders: headers,
                                     explicitEncodedBody: explicitEncodedBody,
                                     timeoutInterval: timeout)
        return request.asURLRequest()
    }
}


extension DawnRemote {

    func fetchLatestRevisions(cursor: String? = "", journalID: String = DawnConstants.journalID) async throws -> [EntryRevision] {
        let path = "/api/v2p5/sync/entries/" + journalID + "/feed"
        let parameters = [
            "cursor": cursor ?? ""
        ]

        let request = request(method: .get, path: path, parameters: parameters)
        return try await runRequest(request, parser: EntryResponseParser())
    }

    func pushEntryRevision(metadata: EntryRevisionMetadata, payload: EntryRevisionPayload) async throws {
        guard let encoder = EntryEncoder(metadata: metadata, payload: payload) else {
            return
        }

        let path = "/api/v3/sync/entries/" + metadata.journalID + "/" + metadata.entryID
        let extraHTTPHeaders = [
            "Content-Type": "multipart/form-data; boundary=\(encoder.boundaryIdentifier)"
        ]

        let request = request(method: .put, path: path, extraHTTPHeaders: extraHTTPHeaders, explicitEncodedBody: encoder.bodyData)
        try await runRequest(request, parser: PassthruResponseParser())
    }
}

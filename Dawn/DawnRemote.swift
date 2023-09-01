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

    func downloadLatestRevisions(cursor: String? = "", journalID: String = DawnConstants.journalID) async throws -> (String, [EntryRevision]) {
        let path = "/api/v2p5/sync/entries/" + journalID + "/feed"
        let parameters = [
            "cursor": cursor ?? ""
        ]

        let request = request(method: .get, path: path, parameters: parameters)
        return try await runRequest(request, parser: EntryFeedParser())
    }

    func submitNewRevision(revision: EntryRevision) async throws -> (EntryUploadOutcome, EntryRevision) {
        guard let encoder = EntryEncoder(revision: revision) else {
            throw SyncError.encodingFailure
        }

        let path = "/api/v3/sync/entries/" + revision.metadata.journalID + "/" + revision.metadata.entryID
        let extraHTTPHeaders = [
            "Content-Type": "multipart/form-data; boundary=\(encoder.boundaryIdentifier)"
        ]

        let request = request(method: .put, path: path, extraHTTPHeaders: extraHTTPHeaders, explicitEncodedBody: encoder.bodyData)
        return try await runRequest(request, parser: EntryUploadResponseParser())
    }
}

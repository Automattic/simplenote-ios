//
//  Downloader.swift
//  SimplenoteShare
//
//  Created by Charlie Scheer on 5/13/24.
//  Copyright © 2024 Automattic. All rights reserved.
//

import Foundation

enum DownloaderError: Error {
    case couldNotFetchNoteContent

    var title: String {
        switch self {
        case .couldNotFetchNoteContent:
            return NSLocalizedString("Could not fetch note content", comment: "note content fetch error title")
        }
    }

    var message: String {
        switch self {
        case .couldNotFetchNoteContent:
            return NSLocalizedString("Attempt to fetch current note content failed.  Please try again later.", comment: "Data Fetch error message")
        }
    }
}

class Downloader: NSObject {

    /// Simperium's Token
    ///
    private let token: String

    /// Designated Initializer
    ///
    init(simperiumToken: String) {
        token = simperiumToken
    }

    func getNoteContent(for simperiumKey: String) async throws -> String? {
        let endpoint = String(format: "%@/%@/%@/i/%@", kSimperiumBaseURL, SPCredentials.simperiumAppID, Settings.bucketName, simperiumKey)
        let targetURL = URL(string: endpoint.lowercased())!

        // Request
        var request = URLRequest(url: targetURL)
        request.httpMethod = Settings.httpMethodGet
        request.setValue(token, forHTTPHeaderField: Settings.authHeader)

        let sc = URLSessionConfiguration.default
        let session = Foundation.URLSession(configuration: sc, delegate: nil, delegateQueue: .main)

        let downloadedData = try await session.data(for: request)

        return try extractNoteContent(from: downloadedData.0)
    }

    func extractNoteContent(from data: Data) throws -> String? {
        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let content =  jsonObject?["content"] as? String else {
            throw DownloaderError.couldNotFetchNoteContent
        }

        return content
    }
}

// MARK: - Settings
//
private struct Settings {
    static let authHeader  = "X-Simperium-Token"
    static let bucketName  = "note"
    static let httpMethodGet  = "GET"
}

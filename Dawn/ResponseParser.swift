//
//  ResponseParser.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


// MARK: - ResponseParser
//
protocol ResponseParser {

    /// The type this parser is expected to return
    ///
    associatedtype Output

    /// Parses a URLRequest's Response, and returns the expected Type, or throws an Error
    ///
    func parse(request: URLRequest, responseData: Data?, response: URLResponse?, error: Error?) throws -> Output
}


// MARK: - CodableResponseParser
//
struct CodableResponseParser<Output: Decodable>: ResponseParser {

    let type: Output.Type
    let decoder: JSONDecoder

    init(type: Output.Type, decoder: JSONDecoder = .mercuryRecordDecoder) {
        self.type = type
        self.decoder = decoder
    }

    func parse(request: URLRequest, responseData: Data?, response: URLResponse?, error: Error? = nil) throws -> Output {
        if let error {
            throw error
        }

        return try autoreleasepool {
            return try decoder.decode(type, from: responseData ?? Data())
        }
    }
}



// MARK: - PassthruResponseParser
//
struct PassthruResponseParser: ResponseParser {

    @discardableResult
    func parse(request: URLRequest, responseData: Data?, response: URLResponse?, error: Error?) throws -> Data {
        if let error {
            throw error
        }

        return responseData ?? Data()
    }
}


// MARK: - EntryFeedParser
//
struct EntryFeedParser: ResponseParser {

    @discardableResult
    func parse(request: URLRequest, responseData: Data?, response: URLResponse?, error: Error?) throws -> (String, [EntryRevision]) {
        if let error {
            throw error
        }

        guard let data = responseData else {
            throw SyncError.parsingFailure
        }

        var lastSeenEnvelope: EntryFeedEnvelope?
        var revisions = [EntryRevision]()
        var cursor: Int = .zero

        for slice in data.splitByNewline() {
            guard let envelope = lastSeenEnvelope else {
                guard let envelope = slice.decode(as: EntryFeedEnvelope.self) else {
                    continue
                }

                switch envelope.revision.type {
                case .delete:
                    let revision = EntryRevision(metadata: envelope.revision, payload: nil)
                    revisions.append(revision)
                default:
                    lastSeenEnvelope = envelope
                }

                continue
            }


            guard let payload = slice.decode(as: EntryRevisionPayload.self) else {
                lastSeenEnvelope = nil
                continue
            }

            let revision = EntryRevision(metadata: envelope.revision, payload: payload)
            revisions.append(revision)

            cursor = envelope.cursor
            lastSeenEnvelope = nil
        }

        return (String(cursor), revisions)
    }
}



// MARK: - EntryUploadResponseParser
//
struct EntryUploadResponseParser: ResponseParser {

    @discardableResult
    func parse(request: URLRequest, responseData: Data?, response: URLResponse?, error: Error?) throws -> (EntryUploadOutcome, EntryRevision) {
        if let error {
            throw error
        }

        guard let slices = responseData?.splitByNewline(), slices.count == 2 else {
            throw SyncError.parsingFailure
        }

        guard
            let response = slices.first?.decode(as: EntryUploadResponse.self),
            let payload = slices.last?.decode(as: EntryRevisionPayload.self)
        else {
            throw SyncError.parsingFailure
        }

        let revision = EntryRevision(metadata: response.revision, payload: payload)
        return (response.outcome, revision)
    }
}



extension Data {

    func decode<T: Decodable>(as type: T.Type) -> T? {
        do {
            return try JSONDecoder.mercuryRecordDecoder.decode(T.self, from: self)
        } catch {
            NSLog("# Decoding Error: \(error)")
        }
        return nil
    }

    func splitByNewline() -> [Data] {
        var bufferRange: Range<Data.Index> = 0 ..< count
        let newline = Data(bytes: "\n", count: 1)
        var output = [Data]()

        while let newlineRange = range(of: newline, in: bufferRange) {
            let slice = subdata(in: bufferRange.lowerBound ..< newlineRange.lowerBound)
            output.append(slice)

            bufferRange = newlineRange.upperBound ..< count
        }

        if bufferRange.count > .zero {
            let slice = subdata(in: bufferRange)
            output.append(slice)
        }

        return output
    }
}

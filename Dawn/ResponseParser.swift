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


// MARK: - ChocolateResponseParser
//
struct ChocolateResponseParser<Output: Decodable>: ResponseParser {

    let type: Output.Type
    let decoder: JSONDecoder

    init(type: Output.Type, decoder: JSONDecoder = .chocolateRecordDecoder) {
        self.type = type
        self.decoder = decoder
    }

    func parse(request: URLRequest, responseData: Data?, response: URLResponse?, error: Error? = nil) throws -> Output {
        if let error {
            throw error
        }

        return try decoder.decode(type, from: responseData ?? Data())
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


// MARK: - EntryResponseParser
//
struct EntryResponseParser: ResponseParser {

    @discardableResult
    func parse(request: URLRequest, responseData: Data?, response: URLResponse?, error: Error?) throws -> [EntryRevision] {
        if let error {
            throw error
        }

        guard let data = responseData else {
            throw SyncError.parsingFailure
        }

        var lastSeenEnvelope: EntryRevisionEnvelope?
        var revisions = [EntryRevision]()

        for slice in data.splitByNewline() {

            guard let envelope = lastSeenEnvelope else {
                lastSeenEnvelope = slice.decode(as: EntryRevisionEnvelope.self)
                continue
            }

            guard let payload = slice.decode(as: EntryRevisionPayload.self) else {
                lastSeenEnvelope = nil
                continue
            }

            let revision = EntryRevision(envelope: envelope, payload: payload)
            revisions.append(revision)
            lastSeenEnvelope = nil
        }

        return revisions
    }
}



extension Data {

    func decode<T: Decodable>(as type: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: self)
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

        return output
    }
}

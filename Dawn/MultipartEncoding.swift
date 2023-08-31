//
//  MultipartEncoding.swift
//  Multipart
//
//  Created by BJ Homer on 7/5/16.
//  Copyright © 2016 BJ Homer. All rights reserved.
//

import Foundation


public struct MultipartBody {

    public enum MultipartType: String {
        case formData = "multipart/form-data"
        case generic  = "multipart/mixed"
        case related  = "multipart/related"
    }

    public let multipartType: MultipartType

    init(_ multipartType: MultipartType = .formData) {
        self.multipartType = multipartType
    }

    let boundaryIdentifier: String = {
        let parts = (1...4).map { _ in String(format: "%x", arc4random()) }
        return "Boundary-" + parts.joined(separator: "")
    }()

    fileprivate var segments: [MultipartSegment] = []

    public var contentType: String {
        return "\(multipartType.rawValue); boundary=\(boundaryIdentifier)"
    }

    public var bodyData: Data {
        let result = NSMutableData()
        let crlf = "\r\n"

        for part in self.segments {
            result.append( ("--"+boundaryIdentifier+crlf).utf8Data )
            result.append( (part.contentDispositionLine+crlf).utf8Data )
            result.append( (part.contentTypeLine+crlf).utf8Data )
            result.append( crlf.utf8Data )
            result.append( part.content )
            result.append( crlf.utf8Data )
        }
        result.append( ("--"+boundaryIdentifier+"--").utf8Data )
        return result as Data
    }

    mutating public func addPart(_ part: MultipartSegment) {
        var mutablePart = part
        if self.multipartType == .formData {
            mutablePart.disposition = "form-data"
        }
        segments.append(mutablePart)
    }

    mutating public func addPart(_ data: Data, mimeType: String, name: String? = nil) {
        addPart(MultipartSegment(data: data, name: name, mimeType: mimeType))
    }

    mutating public func addPart(_ data: Data, name: String) {
        addPart(MultipartSegment(data: data, name: name))
    }

    mutating public func addPart(_ string: String, name: String) {
        addPart(MultipartSegment(string: string, name: name))
    }
}


public struct MultipartSegment {
    var content: Data
    var mimeType: String
    var name: String?
    var filename: String?
    var disposition: String = "attachment"

    public init(data: Data, name: String? = nil, mimeType: String="application/octet-stream") {
        self.content = data
        self.name = name
        self.filename = name
        self.mimeType = mimeType
    }

    public init(string: String, name: String?=nil) {
        self.content = string.utf8Data
        self.mimeType = "text/plain; charset=utf-8"
        self.name = name
        self.filename = nil
    }

    fileprivate var contentDispositionLine: String {
        var resultParts = [disposition]
        if let name = name {
            resultParts.append("name=\"\(name)\"")
        }
        if let filename = filename {
            resultParts.append("filename=\"\(filename)\"")
        }

        return "Content-Disposition: " + resultParts.joined(separator: "; ")
    }

    fileprivate var contentTypeLine: String {
        return "Content-Type: \(mimeType)"
    }
}


public class MultipartEncoder: NSObject {
    fileprivate var body = MultipartBody()
    public func addDataPart(_ data: Data, name: String, mimeType: String) {
        body.addPart(MultipartSegment(data: data, name: name, mimeType: mimeType))
    }
    public func addStringPart(_ string: String, name: String, mimeType: String) {
        body.addPart(string, name: name)
    }
    public var bodyData: Data {
        return body.bodyData
    }
    public var boundaryIdentifier: String {
        return body.boundaryIdentifier
    }
}


private extension String {
    var utf8Data: Data { return self.data(using: String.Encoding.utf8)! }
}

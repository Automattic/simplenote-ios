import Foundation

@objc extension NSString {
    var count: Int {
        let aString = self as String
        return aString.count
    }

    var charCount: Int {
        let aString = self as String
        var result = 0
        for char in aString {
            if !CharacterSet.newlines.contains(char.unicodeScalars.first!) {
                result += 1
            }
        }
        return result
    }

    var wordCount: Int {
        guard length>0 else {
            return 0
        }
        let ChineseCharacterSet = CharacterSet.CJKUniHan.union(CharacterSet.Hiragana).union(CharacterSet.Katakana)
        var result = 0
        enumerateSubstrings(in: NSMakeRange(0, length), options: [.byWords, .localized]) { (substring, substringRange, enclosingRange, stop) in
            if ChineseCharacterSet.contains(substring!.unicodeScalars.first!) {
                result += substring!.count
            } else if !CharacterSet.whitespacesAndNewlines.contains(substring!.unicodeScalars.first!) { // Sometimes NSString treat "\n" and " " as a word.
                result += 1
            }
        }
        return result
    }
}

extension CharacterSet {
    // Chinese characters in Unicode 5.0
    static var CJKUniHanBasic: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0x4E00))!...UnicodeScalar(UInt32(0x9FBB))!)
    }
    static var CJKUniHanExA: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0x3400))!...UnicodeScalar(UInt32(0x4DB5))!)
    }
    static var CJKUniHanExB: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0x20000))!...UnicodeScalar(UInt32(0x2A6D6))!)
    }
    static var CJKUniHanCompatibility1: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0xF900))!...UnicodeScalar(UInt32(0xFA2D))!)
    }
    static var CJKUniHanCompatibility2: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0xFA30))!...UnicodeScalar(UInt32(0xFA6A))!)
    }
    static var CJKUniHanCompatibility3: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0xFA70))!...UnicodeScalar(UInt32(0xFAD9))!)
    }
    static var CJKUniHanCompatibility4: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0x2F800))!...UnicodeScalar(UInt32(0x2FA1D))!)
    }

    static var CJKUniHan: CharacterSet {
        return CJKUniHanBasic.union(CJKUniHanExA).union(CJKUniHanExB).union(CJKUniHanCompatibility1).union(CJKUniHanCompatibility2).union(CJKUniHanCompatibility3).union(CJKUniHanCompatibility4)
    }

    // Japanese Hiraganas and Katakanas
    static var Hiragana: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0x3040))!...UnicodeScalar(UInt32(0x309f))!)
    }
    static var Katakana: CharacterSet {
        return CharacterSet(charactersIn: UnicodeScalar(UInt32(0x30A0))!...UnicodeScalar(UInt32(0x30ff))!).union(CharacterSet(charactersIn: UnicodeScalar(UInt32(0x31f0))!...UnicodeScalar(UInt32(0x31ff))!)
        )
    }

    // gets all characters from a CharacterSet. Only for testing.
    var characters: [UnicodeScalar] {
        var chars = [UnicodeScalar]()
        for plane: UInt8 in 0...16 {
            if self.hasMember(inPlane: plane) {
                let p0 = UInt32(plane) << 16
                let p1 = (UInt32(plane) + 1) << 16
                for c: UInt32 in p0..<p1 {
                    if let us = UnicodeScalar(c) {
                        if self.contains(us) {
                            chars.append(us)
                        }
                    }
                }
            }
        }
        return chars
    }
}

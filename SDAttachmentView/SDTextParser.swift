//
//  SDTextParser.swift
//  SDAttachmentView
//
//  Created by Shidong Lin on 9/4/20.
//

import Foundation

struct ParseResult {
    let location: Int
    let length: Int
}

class SDTextParser {
    let textBlockRegex = try? NSRegularExpression(pattern: "(?<=\\s)(\\w+):")

    func parse(_ query: String) -> [ParseResult] {
        var results = [ParseResult]()
        textBlockRegex?.enumerateMatches(in: query, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: query.count), using: { (result, _, _) in
            if let result = result {
                results.append(ParseResult(location: result.range.location, length: result.range.length))
            }
        })
        return results
    }
}

//
//  String+extension.swift
//
//
//  Created by Tomasz KUCHARSKI on 12/01/2023.
//

import Foundation

extension String {
    subscript(range: Range<Int>) -> String {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return String(self[startIndex..<index(startIndex, offsetBy: range.count)])
    }
}

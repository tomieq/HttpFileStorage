//
//  Optional+extension.swift
//
//
//  Created by Tomasz on 12/01/2023.
//

import Foundation

extension Optional where Wrapped: CustomStringConvertible {
    public var readable: String {
        switch self {
        case .some(let value):
            return value.description
        case .none:
            return "nil"
        }
    }
}

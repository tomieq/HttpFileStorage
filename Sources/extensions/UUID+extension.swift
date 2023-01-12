//
//  UUID+extension.swift
//
//
//  Created by Tomasz on 12/01/2023.
//

import Foundation

extension UUID {
    var shortID: String {
        self.uuidString[0..<8].lowercased()
    }
}

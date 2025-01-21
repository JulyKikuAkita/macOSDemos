//
//  VideoScale.swift
//  MacRecorder
//

import Foundation

enum VideoScale: Int, CaseIterable {
    case normal = 1
    case high = 2
    
    var stringValue: String {
        switch self {
            case .normal:
                return "1X"
            case .high:
                return "2X"
        }
    }
}

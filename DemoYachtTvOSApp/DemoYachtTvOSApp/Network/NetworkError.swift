//
//  NetworkError.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//


import Foundation

/// Unified error type for networking and decoding.
enum NetworkError: LocalizedError {
    case invalidResponse(Int?)
    case decoding(underlying: Error)
    case transport(underlying: Error)
    case cancelled
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let code):
            return "Invalid server response\(code.map { " (\($0))" } ?? "")."
        case .decoding:
            return "Could not parse the data."
        case .transport(let err):
            return "Network issue: \(err.localizedDescription)"
        case .cancelled:
            return "Request cancelled."
        case .unknown:
            return "Something went wrong."
        }
    }
}

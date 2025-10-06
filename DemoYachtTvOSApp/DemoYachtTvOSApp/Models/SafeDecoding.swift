//
//  SafeDecoding.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//

import Foundation


// MARK: - Default-able protocol + defaults
protocol DefaultValue { static var defaultValue: Self { get } }
extension String: DefaultValue { static var defaultValue: String { "" } }
extension Int: DefaultValue { static var defaultValue: Int { 0 } }

@propertyWrapper struct Default<T: DefaultValue & Decodable>: Decodable {
    var wrappedValue: T
    init() { wrappedValue = T.defaultValue }
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        wrappedValue = (try? c.decode(T.self)) ?? T.defaultValue
    }
}
extension Default: Equatable where T: Equatable {}

extension Default: Hashable where T: Hashable {}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Default<T>.Type, forKey key: K) throws -> Default<T>
    where T: DefaultValue & Decodable {
        (try? decodeIfPresent(Default<T>.self, forKey: key)) ?? Default()
    }
}

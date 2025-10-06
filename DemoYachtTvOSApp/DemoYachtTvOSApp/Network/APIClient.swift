//
//  APIClient.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//

import Foundation
import Combine

protocol CrewAPI {
    func fetchCrew() -> AnyPublisher<[CrewMember], NetworkError>
}

final class APIClient: CrewAPI {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://collector-dev.superyachtapi.com")!
    private let session: URLSession

    private init() {
        let cfg = URLSessionConfiguration.default
        cfg.requestCachePolicy = .useProtocolCachePolicy
        cfg.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: "URLCache.tvOS"
        )
        self.session = URLSession(configuration: cfg)
    }

    func fetchCrew() -> AnyPublisher<[CrewMember], NetworkError> {
        let url = baseURL.appendingPathComponent("resources/crew")
        var req = URLRequest(url: url)
        req.timeoutInterval = 30

        return session.dataTaskPublisher(for: req)
            .mapError { err -> NetworkError in
                if (err as NSError).code == NSURLErrorCancelled { return .cancelled }
                return .transport(underlying: err)
            }
            .tryMap { output -> Data in
                guard let http = output.response as? HTTPURLResponse,
                      (200..<300).contains(http.statusCode) else {
                    let code = (output.response as? HTTPURLResponse)?.statusCode
                    throw NetworkError.invalidResponse(code)
                }
                return output.data
            }
            .mapError { $0 as? NetworkError ?? .unknown }
            .decode(type: [CrewMember].self, decoder: JSONDecoder())
            .mapError { .decoding(underlying: $0) }
            .eraseToAnyPublisher()
    }
}

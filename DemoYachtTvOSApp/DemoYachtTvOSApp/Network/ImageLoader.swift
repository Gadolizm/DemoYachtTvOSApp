//
//  ImageLoader.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//


import SwiftUI
import Combine

/// Simple in-memory image cache backed by NSCache.

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()
    private init() { cache.countLimit = 500 }
    subscript(key: NSURL) -> UIImage? {
        get { cache.object(forKey: key) }
        set { newValue == nil ? cache.removeObject(forKey: key) : cache.setObject(newValue!, forKey: key) }
    }
}

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var bag = Set<AnyCancellable>()
    private var currentURL: URL?

    func load(_ url: URL?) {
        guard let url else {
            currentURL = nil
            image = nil
            return
        }
        // If same URL, don’t reload
        if currentURL == url { return }
        currentURL = url
        image = nil

        let key = url as NSURL
        if let cached = ImageCache.shared[key] {
            self.image = cached
            return
        }

        let req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)

        URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { data, response -> UIImage in
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    throw URLError(.badServerResponse)
                }
                guard let img = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                return img
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let e) = completion {
                    print("🖼️ ImageLoader FAIL:", url.absoluteString, e.localizedDescription)
                }
            } receiveValue: { [weak self] img in
                guard let strongSelf = self else { return }
                // Only set if URL didn’t change mid-flight
                if strongSelf.currentURL == url {
                    ImageCache.shared[key] = img
                    strongSelf.image = img
                    print("🖼️ ImageLoader OK:", url.absoluteString)
                }
            }
            .store(in: &bag)
    }

    func cancel() {
        bag.removeAll()
        currentURL = nil
    }
}

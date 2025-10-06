//
//  RemoteCrewCardView 2.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//


import SwiftUI

struct RemoteCrewCardView: View {
    let name: String
    let role: String
    let imageURL: URL?
    var flag: String? = nil     // ← add
    var age: Int? = nil         // ← add

    init(name: String, role: String, imageURL: URL?, flag: String? = nil, age: Int? = nil) {
        self.name = name
        self.role = role
        self.imageURL = imageURL
        self.flag = flag
        self.age = age
    }

    @StateObject private var loader = ImageLoader()

    var body: some View {
        CrewCardView(
            name: name,
            role: role,
            image: loader.image.map { Image(uiImage: $0) },
            flag: flag,
            age: age
        )
        .task(id: imageURL) { loader.load(imageURL) }
        .onDisappear { loader.cancel() }
    }
}


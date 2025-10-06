//
//  AvatarPlaceholderView.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//


import SwiftUI

struct AvatarPlaceholderView: View {
    let name: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.06))
            Text(initials(from: name))
                .font(.system(size: 64, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
    }
    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let a = parts.first?.first.map(String.init) ?? "?"
        let b = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }
}

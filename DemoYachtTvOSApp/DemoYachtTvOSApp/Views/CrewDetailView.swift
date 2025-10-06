//
//  CrewDetailView.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//


import SwiftUI

struct CrewDetailView: View {
    let name: String
    let role: String
    let age: Int?
    let countryCode: String?
    let bio: String?
    let imageURL: URL?

    @Environment(\.dismiss) private var dismiss
    @StateObject private var loader = ImageLoader()

    private let corner: CGFloat = 32

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Fullscreen backdrop
                LinearGradient(
                    colors: [Color(red: 0.06, green: 0.18, blue: 0.30),
                             Color(red: 0.04, green: 0.30, blue: 0.40)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Main content container (glassy)
                HStack(alignment: .top, spacing: 40) {
                    // LEFT: text column
                    VStack(alignment: .leading, spacing: 18) {
                        if !role.isEmpty {
                            Text(role)
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.75))
                        }

                        Text(name.isEmpty ? "Crew Member" : name)
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(.white)

                        if age != nil || countryCode != nil {
                            HStack(spacing: 12) {
                                if let age, age > 0 { Text("\(age) years old") }
                                if let cc = countryCode, let flag = flagEmoji(from: cc) {
                                    Text(flag).font(.title2)
                                    Text(countryName(from: cc))
                                } else if let cc = countryCode {
                                    Text(countryName(from: cc))
                                }
                            }
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.9))
                        }

                        if let bio, !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(bio)
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.92))
                                .lineSpacing(6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Spacer(minLength: 0)
                    }
                    .frame(width: min(540, geo.size.width * 0.38), alignment: .leading)
                    .padding(.vertical, 8)

                    // RIGHT: big rounded image
                    ZStack {
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .fill(.white.opacity(0.08))

                        if let img = loader.image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()  // like the reference
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                        } else {
                            ProgressView().scaleEffect(1.4).tint(.white)
                        }
                    }
                    .frame(
                        width: max(700, geo.size.width * 0.45),
                        height: max(500, geo.size.height * 0.65)
                    )
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 40)
                .background(.ultraThinMaterial, in:
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                )
                .padding(.horizontal, 40)
                .padding(.vertical, 30)
            }
        }
        .onAppear { loader.load(imageURL) }
        .onExitCommand { dismiss() }   // Back/Esc to close
        .accessibilityHint("Press Back to close")
    }

    // Helpers
    private func flagEmoji(from countryCode: String) -> String? {
        let code = countryCode.uppercased()
        guard code.count == 2 else { return nil }
        let base: UInt32 = 0x1F1E6
        var scalars = String.UnicodeScalarView()
        for u in code.unicodeScalars {
            let v = u.value
            guard v >= 65 && v <= 90 else { return nil }
            scalars.append(UnicodeScalar(base + (v - 65))!)
        }
        return String(scalars)
    }
    private func countryName(from countryCode: String) -> String {
        let locale = Locale(identifier: Locale.preferredLanguages.first ?? "en_US")
        return locale.localizedString(forRegionCode: countryCode.uppercased()) ?? countryCode
    }
}

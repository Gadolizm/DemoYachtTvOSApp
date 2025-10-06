//
//  CrewCardView.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//


import SwiftUI

/// Focusable tvOS crew card with name, role, and optional image.
/// Use RemoteCrewCardView to load images from URL.

struct CrewCardView: View {
    let name: String
    let role: String
    let image: Image?
    var flag: String? = nil
    var age: Int? = nil
    var onTap: (() -> Void)? = nil
    
    // Layout
    private let cardSize = CGSize(width: 360, height: 360)
    private let imageHeight: CGFloat = 200
    private let corner: CGFloat = 22
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Button(action: { onTap?() }) {
            ZStack {
                // Card shell
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.white.opacity(0.08))
                
                VStack(alignment: .leading, spacing: 10) {
                    // HEADER — smaller, lighter typography
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(name.isEmpty ? "Unnamed" : name)
                                .font(.callout)                 // smaller than headline
                                .fontWeight(.semibold)          // lighter than bold
                                .foregroundStyle(.white.opacity(0.95))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            
                            Text(role.isEmpty ? "—" : role)
                                .font(.footnote)                // smaller
                                .fontWeight(.regular)           // lighter
                                .foregroundStyle(.white.opacity(0.75))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .padding(.leading, 14)
                        .padding(.top, 12)
                        
                        Spacer(minLength: 6)
                        
                        // Flag + age — compact pills
                        HStack(spacing: 6) {
                            if let age, age > 0 {
                                Text("\(age)")
                                    .font(.caption.weight(.semibold))  // smaller
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                            if let flag { Text(flag).font(.callout) } // compact flag
                        }
                        .padding(.trailing, 12)
                        .padding(.top, 8)
                    }
                    
                    if let image {
                        image
                            .resizable()
                            .frame(maxWidth: cardSize.width,
                                   maxHeight: imageHeight,
                                   alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: corner - 4, style: .continuous))
                            .overlay(
                                LinearGradient(colors: [.clear, .black.opacity(0.15)],
                                               startPoint: .center, endPoint: .bottom)
                                .clipShape(RoundedRectangle(cornerRadius: corner - 4, style: .continuous))
                            )
                            .padding(.horizontal, 12)
                    } else {
                        AvatarPlaceholderView(name: name)
                            .clipShape(RoundedRectangle(cornerRadius: corner - 4, style: .continuous))
                    }
                }
            }
            .frame(width: cardSize.width, height: cardSize.height)
            // Perfect outline using the same radius as the shell
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(.white.opacity(isFocused ? 0.28 : 0.10), lineWidth: 1)
            )
            // Clean focus effect (no 3D tilt → keeps shape “well”)
            .shadow(color: .black.opacity(isFocused ? 0.55 : 0.25),
                    radius: isFocused ? 22 : 10,
                    x: 0, y: isFocused ? 10 : 5)
            .scaleEffect(isFocused ? 1.06 : 1.0)
            .animation(.easeOut(duration: 0.18), value: isFocused)
            .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
        }
        .buttonStyle(.plain) // tvOS: no default chrome
        .focusable(true)
        .focused($isFocused)
    }
    
    private var accessibilityLabel: String {
        var parts = [String]()
        parts.append(name.isEmpty ? "Crew Member" : name)
        if !role.isEmpty { parts.append(role) }
        if let age { parts.append("Age \(age)") }
        return parts.joined(separator: ", ")
    }
}


// AAIcon.swift
// Reusable SF Symbol wrapper with app theme defaults.

import SwiftUI

struct AAIcon: View {
    let name: String
    let size: CGFloat
    let weight: Font.Weight
    let color: Color

    init(
        _ name: String,
        size: CGFloat = 17,
        weight: Font.Weight = .semibold,
        color: Color = AATheme.primaryText
    ) {
        self.name = name
        self.size = size
        self.weight = weight
        self.color = color
    }

    var body: some View {
        Image(systemName: name)
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }
}

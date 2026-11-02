
import SwiftUI
import UIKit

struct MBArtworkView: View {
    let artworkName: String
    let fallbackEmoji: String
    var height: CGFloat = 150

    var body: some View {
        if let artworkImage = UIImage(named: artworkName) {
            Image(uiImage: artworkImage)
                .resizable()
                .scaledToFit()
                .frame(height: height)
        } else {
            ZStack {
                Circle()
                    .fill(MBColors.paperDeep)
                    .frame(width: height * 0.82, height: height * 0.82)
                    .overlay(Circle().stroke(MBColors.outline, lineWidth: 2))
                    .background(Circle().fill(MBColors.hardShadow).offset(x: 4, y: 4))
                Text(fallbackEmoji)
                    .font(.system(size: height * 0.38))
            }
            .frame(height: height)
        }
    }
}

struct MBTabGlyph: View {
    let artworkName: String
    let fallbackSymbol: String
    let tint: Color

    var body: some View {
        if let glyphImage = UIImage(named: artworkName) {
            Image(uiImage: glyphImage)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(tint)
        } else {
            Image(systemName: fallbackSymbol)
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(tint)
                .frame(width: 24, height: 24)
        }
    }
}

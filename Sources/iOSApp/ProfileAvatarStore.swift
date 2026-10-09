import Foundation
import Combine
import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@MainActor
final class ProfileAvatarStore: ObservableObject {
    @Published private(set) var imageData: Data?

    private let defaults: UserDefaults
    private let key = "scp_profile_avatar_v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.imageData = defaults.data(forKey: key)
    }

    func save(_ data: Data) {
        imageData = data
        defaults.set(data, forKey: key)
    }

    func remove() {
        imageData = nil
        defaults.removeObject(forKey: key)
    }
}

struct ProfileAvatarView: View {
    let imageData: Data?
    var size: CGFloat = 72

    var body: some View {
        Group {
            if let imageData, let image = PlatformImage(data: imageData) {
                Image(platformImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.14)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .background(.thinMaterial, in: Circle())
        .clipShape(Circle())
        .overlay(Circle().stroke(.white.opacity(0.45), lineWidth: 1))
    }
}

#if os(iOS)
private typealias PlatformImage = UIImage
private extension Image {
    init(platformImage: UIImage) { self.init(uiImage: platformImage) }
}
#elseif os(macOS)
private typealias PlatformImage = NSImage
private extension Image {
    init(platformImage: NSImage) { self.init(nsImage: platformImage) }
}
#else
private struct PlatformImage {}
private extension Image {
    init(platformImage: PlatformImage) { self.init(systemName: "person.crop.circle.fill") }
}
#endif

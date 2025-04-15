import SwiftUI

// MARK: App entrypoint
@MainActor
@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup(id: "game") {
            GameView()
                .volumeBaseplateVisibility(.hidden)
        }
        .windowStyle(.volumetric)
        .volumeWorldAlignment(.gravityAligned)
        .defaultSize(width: 0.7, height: 2, depth: 0.7, in: .meters)
    }
}



//
//  MacRecorderApp.swift
//  MacRecorder
//

import SwiftUI

@main
struct MacRecorderApp: App {
    @AppStorage("isUserIntroCompleted") private var isUserIntroCompleted: Bool = false
    @State private var introScreenShowed: Bool = false
    /// Environment Values
    @Environment(\.openWindow) private var openWindow
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        MenuBarExtra("Mac Recorder", systemImage: "inset.filled.rectangle.badge.record", isInserted: .constant(isUserIntroCompleted)) {
            MenuView()
        }
        .menuBarExtraStyle(.window)
        .onChange(of: scenePhase, initial: true) { oldValue, newValue in
            if !isUserIntroCompleted && !introScreenShowed {
                openWindow(id: "IntroView")
                introScreenShowed = true
            }
        }
        
        WindowGroup(id: "IntroView") {
            IntroView()
        }
        .windowLevel(.floating)
        .windowStyle(.plain)
        .restorationBehavior(.disabled)
        /// placing at the center of the screen
        .defaultWindowPlacement { content, context in
            let displaySize = context.defaultDisplay.visibleRect.size
            let size = content.sizeThatFits(.init(displaySize))
            
            return .init(.center, size: size)
        }
    }
}

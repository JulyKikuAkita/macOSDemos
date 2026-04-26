//
//  macOSDemosApp.swift
//  macOSDemos
//
// ============================================================
// SINGLE ENTRY POINT — how to add a new demo
//
//  1. Create your View in the View/ folder (no @main needed).
//  2. If your demo opens extra windows (openWindow(id:) or
//     openWindow(value:)), register those WindowGroups here.
//  3. Add a new case to the Demo enum below.
//  4. Add a case to DemoDetailView's body switch.
//  That's it — no @main shuffling required.
// ============================================================

import SwiftUI

@main
struct macOSDemosApp: App {
    var body: some Scene {
        WindowGroup {
            DemoListView()
        }

        // ── Drag & Drop preview window ────────────────────────
        if #available(macOS 26, *) {
            WindowGroup(id: "PREVIEWWINDOW", for: URL.self) { value in
                DragDropPreviewWindowView(url: value)
                    .frame(width: 250, height: 200)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .windowStyle(.plain)
            .windowLevel(.floating)
            .restorationBehavior(.disabled)
            .windowResizability(.contentSize)
            .defaultWindowPlacement { _, context in
                .init(size: context.defaultDisplay.visibleRect.size)
            }
        }

        // ── Toast ─────────────────────────────────────────────
        // Each toast is its own floating window; see ToastWindow's
        // .windowLevel(.floating) and .windowStyle(.plain) for why.
        ToastWindow()

        // ── Floating / Alert windows ───────────────────────────
        // These scenes must live here even though the trigger UI is
        // in FloatingWindow.swift — openWindow(id:) matches by the
        // id registered in the @main App, not the file it's in.
        WindowGroup(id: "FloatingWindow") {
            FloatingWindow()
                .simultaneousGesture(WindowDragGesture())
                .toolbarVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.clear, for: .window)
        }
        .windowLevel(.floating)
        .windowResizability(.contentSize)
        .windowStyle(.plain)

        WindowGroup(id: "AlertWindow") {
            AlertWindow()
                .allowsHitTesting(false)
                .toolbarVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.clear, for: .window)
        }
        .windowLevel(.floating)
        .windowBackgroundDragBehavior(.disabled)
        .windowResizability(.contentSize)
        .windowStyle(.plain)
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { content, context in
            let size = content.sizeThatFits(.init(context.defaultDisplay.visibleRect.size))
            return .init(.init(x: 0, y: 1), size: size)
        }

        // ── Xcode Onboarding (classic) ─────────────────────────
        // Uses id "Xcode-Animation" to avoid colliding with the
        // macOS 26 version which also uses id "OnBoarding".
        WindowGroup(id: "Xcode-Animation") {
            XcodeOnBoardingView(foregroundColor: .white, tint: .blue) { isAnimating in
                Image(systemName: "hammer.fill")
                    .font(.system(size: 250))
                    .blendMode(.softLight)
                    .scaleEffect(isAnimating ? 0.5 : 1)
            } content: { _ in
                VStack(spacing: 15) {
                    Text("Welcome to Xcode")
                        .font(.largeTitle.bold())
                    Button {
                    } label: {
                        Text("Continue")
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(maxWidth: 230)
                            .padding(.vertical, 12)
                            .background(.blue.gradient, in: .capsule)
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
            }
            .gesture(WindowDragGesture())
        }
        .windowStyle(.plain)
        .restorationBehavior(.disabled)

        // ── Xcode Onboarding macOS 26 ──────────────────────────
        // XcodeOnBoarding26Window is @available(macOS 26, *), so
        // wrap it with if #available — SceneBuilder supports this.
        if #available(macOS 26, *) {
            XcodeOnBoarding26Window(
                items: sampleOnBoardingMenuItems,
                onExit: {}, onSkip: {}, onComplete: {}
            )
        }
    }
}

// MARK: - Sidebar Navigation

private struct DemoListView: View {
    @State private var selection: Demo? = .toast

    var body: some View {
        NavigationSplitView {
            List(Demo.allCases, selection: $selection) { demo in
                Label(demo.title, systemImage: demo.icon)
                    .tag(demo)
            }
            .navigationTitle("macOS Demos")
        } detail: {
            if let selection {
                DemoDetailView(demo: selection)
            } else {
                Text("Select a demo")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Demo Registry
// Add a new case here when adding a demo. The enum drives both the
// sidebar list and the detail view — one place to update.

private enum Demo: String, CaseIterable, Identifiable {
    case toast          = "Toast"
    case floatingWindow = "Floating Window"
    case alertWindow    = "Alert Window"
    case onboarding     = "Xcode Onboarding"
    case onboarding26   = "Xcode Onboarding (macOS 26)"
    case dragDrop       = "Drag & Drop"

    var id: Self { self }

    var title: String { rawValue }

    var icon: String {
        switch self {
        case .toast:          "bubble.fill"
        case .floatingWindow: "macwindow.on.rectangle"
        case .alertWindow:    "exclamationmark.triangle.fill"
        case .onboarding:     "sparkles"
        case .onboarding26:   "sparkles.rectangle.stack.fill"
        case .dragDrop:       "arrow.up.and.down.and.arrow.left.and.right"
        }
    }
}

// MARK: - Detail Switcher

private struct DemoDetailView: View {
    var demo: Demo
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        switch demo {
        case .toast:
            MacOS26ToastDemoView()

        case .floatingWindow:
            // FloatingWindowDemoView has its own openWindow(id: "FloatingWindow") button
            FloatingWindowDemoView()

        case .alertWindow:
            AlertWindowDemoView()

        case .onboarding:
            // The onboarding UI is a standalone .plain window; open it separately
            // so WindowDragGesture and the custom chrome work correctly.
            windowLauncher("Show Xcode Animation", icon: "sparkles") {
                openWindow(id: "Xcode-Animation")
            }

        case .onboarding26:
            if #available(macOS 26, *) {
                windowLauncher("Open Onboarding Window (macOS 26)", icon: "sparkles.rectangle.stack.fill") {
                    openWindow(id: "OnBoarding")
                }
            } else {
                unavailableView("Requires macOS 26")
            }

        case .dragDrop:
            DragDropDemoView()

        }
    }

    @ViewBuilder
    private func windowLauncher(_ label: String, icon: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Button(label, action: action)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func unavailableView(_ message: String) -> some View {
        ContentUnavailableView(message, systemImage: "xmark.circle")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

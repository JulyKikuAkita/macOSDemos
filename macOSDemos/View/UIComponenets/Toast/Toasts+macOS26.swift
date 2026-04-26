//
//  Toasts+macOS26.swift
//  macOSDemos
//
//  Created on 4/26/26.
//
// ============================================================
// LEARNING GUIDE: macOS Toast Notifications with SwiftUI
// ============================================================
//
// WHY A SEPARATE WINDOW INSTEAD OF AN OVERLAY?
//   On macOS, a SwiftUI overlay or ZStack is clipped to its parent window's bounds.
//   To float content above the menu bar, Dock, and all other windows, you need a
//   dedicated NSWindow. SwiftUI exposes this via WindowGroup + openWindow(value:).
//
// REQUIREMENT: Every WindowGroup must be registered in @main App.
//   openWindow(value:) matches by the type you pass. If the corresponding
//   WindowGroup(id:for:) is missing from the App body, you get:
//   "No Scene presenting type 'YourType' is defined"
//   Fix: add your custom Scene (e.g. ToastWindow()) to the @main App body.
//
// THE CASCADE WINDOW PROBLEM — why toasts scatter on screen:
//   SwiftUI always enables NSWindowController's shouldCascadeWindows.
//   There is no SwiftUI API to disable it. defaultWindowPlacement only sets
//   the FIRST window's position; every subsequent window is offset by ~20 pt.
//   Fix: bridge to AppKit via NSViewRepresentable and call
//   NSWindow.setFrameOrigin(_:) directly after the window is on screen.
//
// macOS COORDINATE SYSTEM — the "upside-down" trap:
//   Unlike UIKit/iOS where (0,0) is the top-left corner, AppKit/NSWindow uses
//   a coordinate system where (0,0) is the BOTTOM-LEFT of the screen.
//   Y increases upward. Always account for this when computing window origins.
//   e.g. anchor.y = 0.99 → near the bottom; anchor.y = 0.01 → near the top.
//
// @main RULE — only one entry point per module:
//   A Swift module can have exactly one @main. If you move @main here (as this
//   file does), remove or comment it out from macOSDemosApp.swift, otherwise
//   you get: "'main' attribute cannot be used in a module that contains
//   top-level code."
//
// GLASSMORPHISM — glassEffect vs ultraThinMaterial:
//   macOS 26 introduced .glassEffect() for the new liquid-glass appearance.
//   Use #available(macOS 26, *) guards and fall back to .ultraThinMaterial
//   for macOS 15 and earlier so the app runs on older OS versions.
//
// AnyLayout — runtime layout switching:
//   AnyLayout lets you choose between HStackLayout and VStackLayout at runtime
//   without type-erasing the entire view. Useful for adaptive components that
//   change shape based on content or user preference.
// ============================================================

import SwiftUI

// MARK: - Demo View

struct MacOS26ToastDemoView: View {
    @Environment(\.openWindow) private var openWindow

    private func show(_ toast: MacToast) {
        openWindow(value: toast)
    }

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                sectionLabel("Vertical Style")
            }
            GridRow {
                // anchor (0.5, 0.99) → bottom-center of screen
                toastButton("Build Succeeded", icon: "checkmark.seal.fill", tint: .green) {
                    MacToast(id: UUID().uuidString, toastStyle: .vertical,
                             symbol: "checkmark.seal.fill",
                             title: "Build Succeeded",
                             subtitle: "Compiled and linted successfully.\nNo issues reported.",
                             anchor: .init(x: 0.5, y: 0.99), dismissDuration: 2)
                }
                toastButton("Network Error", icon: "wifi.slash", tint: .red) {
                    MacToast(id: UUID().uuidString, toastStyle: .vertical,
                             symbol: "wifi.slash",
                             title: "Network Error",
                             subtitle: "Connection lost.\nCheck your internet settings.",
                             anchor: .init(x: 0.5, y: 0.99), dismissDuration: 4)
                }
            }
            GridRow {
                // anchor (0.9, 0.99) → bottom-right of screen
                toastButton("Download Started", icon: "arrow.down.circle.fill", tint: .blue) {
                    MacToast(id: UUID().uuidString, toastStyle: .vertical,
                             symbol: "arrow.down.circle.fill",
                             title: "Downloading…",
                             subtitle: "Archive.zip · 142 MB",
                             anchor: .init(x: 0.9, y: 0.99), dismissDuration: 3)
                }
                // anchor (0.5, 0.01) → top-center of screen (y flipped: small y = near top)
                toastButton("Top-Center Alert", icon: "exclamationmark.triangle.fill", tint: .orange) {
                    MacToast(id: UUID().uuidString, toastStyle: .vertical,
                             symbol: "exclamationmark.triangle.fill",
                             title: "Low Disk Space",
                             subtitle: "Only 2 GB remaining on Macintosh HD.",
                             anchor: .init(x: 0.5, y: 0.01), dismissDuration: 3)
                }
            }

            GridRow {
                sectionLabel("Horizontal Style")
            }
            GridRow {
                toastButton("Saved", icon: "checkmark.circle.fill", tint: .green) {
                    MacToast(id: UUID().uuidString, toastStyle: .horizontal,
                             symbol: "checkmark.circle.fill",
                             title: "Saved",
                             anchor: .init(x: 0.5, y: 0.99), dismissDuration: 1.5)
                }
                toastButton("Upload Complete", icon: "arrow.up.circle.fill", tint: .blue) {
                    MacToast(id: UUID().uuidString, toastStyle: .horizontal,
                             symbol: "arrow.up.circle.fill",
                             title: "Upload Complete",
                             anchor: .init(x: 0.5, y: 0.99), dismissDuration: 2)
                }
            }
            GridRow {
                // symbol: nil demonstrates the optional SF Symbol — layout still works
                toastButton("No Symbol", icon: "textformat", tint: .purple) {
                    MacToast(id: UUID().uuidString, toastStyle: .horizontal,
                             symbol: nil,
                             title: "Reminder set for 3:00 PM",
                             anchor: .init(x: 0.5, y: 0.99), dismissDuration: 2)
                }
                // anchor (0.98, 0.99) → bottom-right corner, like macOS Notification Center
                toastButton("Bottom-Right Corner", icon: "bell.fill", tint: .yellow) {
                    MacToast(id: UUID().uuidString, toastStyle: .horizontal,
                             symbol: "bell.fill",
                             title: "New message from Alex",
                             anchor: .init(x: 0.98, y: 0.99), dismissDuration: 3)
                }
            }
        }
        .padding(20)
    }

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.secondary)
            .gridCellColumns(2)
    }

    @ViewBuilder
    private func toastButton(_ label: String, icon: String, tint: Color, toast: @escaping () -> MacToast) -> some View {
        Button(action: { show(toast()) }) {
            Label(label, systemImage: icon)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(tint)
        .controlSize(.large)
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - Toast Data Model
//
// MacToast must be Codable + Hashable because WindowGroup(id:for:) uses it as
// a navigation value — SwiftUI serializes it to pass between the caller and the
// new window's environment. Any non-Codable property would break this.
//
// anchor uses normalized coordinates (0–1) relative to the screen, so toasts
// reposition correctly across different screen sizes and resolutions.
struct MacToast: Codable, Hashable, Identifiable {
    var id: String
    var toastStyle: ToastStyle
    var symbol: String?
    var title: String
    var subtitle: String?
    // Normalized (0–1, 0–1): x=0 is left edge, x=1 is right edge,
    // y=0 is top edge, y=1 is bottom edge (converted in WindowAnchorAdjust).
    var anchor: CGPoint = .init(x: 0.5, y: 0.99)
    var dismissDuration: CGFloat = 2

    enum ToastStyle: String, Codable {
        case vertical   = "Vertical"    // icon above title — richer card
        case horizontal = "Horizontal"  // icon left of title — compact pill
    }
}

// MARK: - Toast Scene
//
// Encapsulating the WindowGroup in its own Scene type keeps the @main App body
// clean and makes ToastWindow reusable across projects.
//
// Key window modifiers explained:
//   .windowLevel(.floating)          — renders above the app's main window
//   .windowStyle(.plain)             — removes title bar and standard chrome
//   .restorationBehavior(.disabled)  — prevents macOS restoring stale toasts on relaunch
//   .windowBackgroundDragBehavior(.disabled) — stops accidental window dragging
struct ToastWindow: Scene {
    var body: some Scene {
        WindowGroup(id: "Mac-Toast", for: MacToast.self) { toast in
            if let toast = toast.wrappedValue {
                MacToastView(toast: toast)
            }
        }
        .windowLevel(.floating)
        .windowStyle(.plain)
        .restorationBehavior(.disabled)
        .windowBackgroundDragBehavior(.disabled)
    }
}

// MARK: - Toast View

private struct MacToastView: View {
    var toast: MacToast
    @Environment(\.dismiss) private var dismiss
    let cornerRadius: CGFloat = 20  // rounded rect radius; matches macOS 15+ system style
    @State private var isVisible: Bool = false

    var body: some View {
        ZStack {
            // glassEffect is a macOS 26+ API for the liquid-glass material.
            // Always provide a fallback for earlier OS versions.
            if #available(macOS 26, *) {
                toastView()
                    .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            } else {
                toastView()
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
            }
        }
        // WindowAnchorAdjust is an invisible NSView used purely to reach the
        // underlying NSWindow and override its frame origin. This is the escape
        // hatch around SwiftUI's lack of per-window position control.
        .background(WindowAnchorAdjust(anchor: toast.anchor))
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            let animation = Animation.easeInOut(duration: 0.25)
            withAnimation(animation) { isVisible = true }

            // completionCriteria: .logicallyComplete fires the completion block
            // as soon as the animation's logical state finishes (not after spring
            // overshoot settles), giving a snappier dismiss.
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.dismissDuration) {
                withAnimation(animation, completionCriteria: .logicallyComplete) {
                    isVisible = false
                } completion: {
                    dismiss()
                }
            }
        }
        // Toasts are purely informational — block all pointer interaction so
        // clicks fall through to whatever is behind the window.
        .allowsHitTesting(false)
    }

    // AnyLayout lets us switch between HStackLayout and VStackLayout at runtime
    // without branching the entire view body. Introduced in iOS 16 / macOS 13.
    private func toastView() -> some View {
        let isHorizontal = toast.toastStyle == .horizontal
        let layout = isHorizontal
            ? AnyLayout(HStackLayout(spacing: 8))
            : AnyLayout(VStackLayout(spacing: 15))

        return layout {
            if let symbol = toast.symbol {
                Image(systemName: symbol)
                    .font(.system(size: isHorizontal ? 15 : 50))
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .center, spacing: 4) {
                Text(toast.title)
                    .font(.system(size: isHorizontal ? 12 : 16))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .fixedSize()

                if let subtitle = toast.subtitle, !isHorizontal {
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .fixedSize()
                }
            }
        }
        .padding(.horizontal, isHorizontal ? 15 : 20)
        .padding(.vertical, isHorizontal ? 0 : 20)
        .frame(height: isHorizontal ? 45 : nil)
    }
}

// MARK: - Window Position Fix (NSViewRepresentable)
//
// Problem: SwiftUI has no API to set a window's absolute screen position from
// within the view, and shouldCascadeWindows offsets each new window of the same
// WindowGroup by ~20 pt, breaking a consistent bottom-center anchor.
//
// Solution: Embed an invisible NSView. Once it is added to the view hierarchy,
// its `.window` property gives us access to the NSWindow. We then call
// setFrameOrigin(_:) to pin the window to the computed screen coordinate.
//
// Why DispatchQueue.main.async?
//   view.window is nil during makeNSView because the view hasn't been inserted
//   into a window yet. Deferring one run-loop tick guarantees the window exists.
//
// Coordinate math (macOS origin = bottom-left):
//   screenX = screenFrame.minX + screenFrame.width  * anchor.x
//   screenY = screenFrame.minY + screenFrame.height * (1 - anchor.y)
//   Then subtract the window's own offset so the anchor point on the WINDOW
//   aligns with the anchor point on the SCREEN (not the window's top-left corner).
private struct WindowAnchorAdjust: NSViewRepresentable {
    var anchor: CGPoint

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.layer?.backgroundColor = .clear
        DispatchQueue.main.async {
            if let window = view.window {
                setWindowAnchor(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    private func setWindowAnchor(_ window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let windowFrame = window.frame
        let screenFrame = screen.visibleFrame

        // Convert normalized anchor to absolute screen coordinates.
        let screenX = screenFrame.minX + screenFrame.width  * anchor.x
        let screenY = screenFrame.minY + screenFrame.height * (1 - anchor.y)

        // Subtract the window's own anchor offset so the desired point on the
        // window aligns with the desired point on the screen.
        let windowOffsetX = windowFrame.width  * anchor.x
        let windowOffsetY = windowFrame.height * (1 - anchor.y)

        window.setFrameOrigin(.init(
            x: screenX - windowOffsetX,
            y: screenY - windowOffsetY
        ))
    }
}

#Preview {
    MacOS26ToastDemoView()
}

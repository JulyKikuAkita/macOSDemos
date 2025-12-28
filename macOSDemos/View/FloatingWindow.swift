//
//  FloatingWindow.swift
//  macOSDemos
//
import SwiftUI

/// Make floating window drag-able by
///  1.1
///     FloatingWindow()
///        .allowsHitTesting(false) /// 1. so that we can directly interact with bg
/// 1.2
///     WindowGroup(id: "FloatingWindow") {
///        FloatingWindow()
///     }
///     .windowBackgroundDragBehavior(.enabled) /// drag-able on bg
///
/// or 2: use FloatingWindow()..simultaneousGesture(WindowDragGesture()) /// when overlay a close button on floating window

//@main
struct FloatingWindowDemoApp: App {
    var body: some Scene {
        WindowGroup {
//            FloatingWindowDemoView()
            AlertWindowDemoView()
        }
        
        WindowGroup(id: "FloatingWindow") {
            FloatingWindow()
//                .allowsHitTesting(false) /// 1. so that we can directly interact with bg
                .simultaneousGesture(WindowDragGesture()) /// make window draggable
                .toolbarVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.clear, for: .window) /// hide image background
        }
        .windowLevel(.floating)
//        .windowBackgroundDragBehavior(.enabled) /// #1 drag-able on the image background
        .windowResizability(.contentSize) /// Avoid resizability
        .windowStyle(.plain)
        
        
        WindowGroup(id: "AlertWindow") {
            AlertWindow()
                .allowsHitTesting(false) /// 1. so that we can directly interact with bg
                .toolbarVisibility(.hidden, for: .windowToolbar)
                .containerBackground(.clear, for: .window) /// hide image background
        }
        .windowLevel(.floating)
        .windowBackgroundDragBehavior(.disabled)
        .windowResizability(.contentSize) /// Avoid resizability
        .windowStyle(.plain)
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { content, context in
            let viewSize = content.sizeThatFits(.init(context.defaultDisplay.visibleRect.size))
            return .init(.init(x: 0, y: 1), size: viewSize) /// try (x: 1, y:0) location
        }
        
    }
}

struct FloatingWindowDemoView: View {
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        Button("Show Floating Window") {
            openWindow(id: "FloatingWindow")
        }
    }
}

struct FloatingWindow: View {
    @State private var isHovering: Bool = false
    @Environment(\.dismissWindow) private var dismissWindow
    var body: some View {
        Image(.fox)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .overlay {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Button {
                            dismissWindow()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                        }
                        .buttonStyle(.plain)
                    }
                    .opacity(isHovering ? 1 : 0)
                    .animation(.smooth(), value: isHovering)
            }
            .onHover {
                isHovering = $0
            }
            .clipShape(.rect(cornerRadius: 30))
    }
}

struct AlertWindowDemoView: View {
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        ContentView()
        Button("Show Alert Window") {
            openWindow(id: "AlertWindow")
        }
    }
}


struct AlertWindow: View {
    @State private var showAlert: Bool = false
    @Environment(\.dismissWindow) private var dismissWindow
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
            
            VStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundStyle(.primary.secondary)
                
                Text("Saved Successfully")
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
            }
        }
        .frame(width: 200, height: 200)
        .opacity(showAlert ? 1 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.25)) {
                showAlert = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.25), completionCriteria: .logicallyComplete) {
                    showAlert = false
                } completion: {
                    dismissWindow()
                }
            }
        }
    }
}

#Preview {
    FloatingWindowDemoView()
}

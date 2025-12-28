//
//  DragDropDemoView.swift
//  macOSDemos
//
//  Created by July on 12/27/25.
//

import SwiftUI
@available(macOS 26.0, *)
@main
struct ScreenShotPreviewAnimationApp: App {
    var body: some Scene {
        WindowGroup {
            DragDropDemoView()
        }

        WindowGroup(id: "PREVIEWWINDOW", for: URL.self) { value in
            PreviewWindowView(url: value)
                .frame(
                    width: previewWindowSize.width,
                    height: previewWindowSize.height,
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: previewWindowAnchor
                )
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        .restorationBehavior(.disabled)
        .windowResizability(.contentSize)
        .defaultWindowPlacement { content, context in
            return .init(size: context.defaultDisplay.visibleRect.size)
        }
    }

    var previewWindowSize: CGSize {
        return .init(width: 250, height: 200)
    }

    var previewWindowAnchor: Alignment {
        return .bottomTrailing
    }
}

@available(macOS 26.0, *)
fileprivate  struct PreviewWindowView: View {
    @Binding var url: URL?
    /// View Properties
    @State private var previewImage: NSImage?
    @State private var isHovered: Bool = false
    @State private var hideView: Bool = false

    @Environment(\.dismiss) private var dismissWindow
    var body: some View {
        ZStack {
            if let previewImage, let url {
                Image(nsImage: previewImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        if isHovered {
                            hoverContent()
                        }
                    }
                    .clipShape(.rect(cornerRadius: 20))
                    .opacity(hideView ? 0 : 1)
                    .draggable(url) {
                        Image(nsImage: previewImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 20))
                    }
                    .onDragSessionUpdated { session in
                        let phase = session.phase
                        if phase == .active {
                            hideView = true
                        }
                        if case .ended(let dropOperation) = phase {
                            print(dropOperation)
                            /// remove the file
                            try? FileManager.default.removeItem(at: url)
                            dismissWindow()
                        }
                    }
                    .onHover { status in
                        withAnimation(animation) {
                            isHovered = status
                        }
                    }
                    .transition(.push(from: .trailing))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if let url, let image = NSImage(contentsOf: url) {
                withAnimation(animation) {
                    previewImage = image
                }
            } else {
                print("No Image Found. Close the window.")
                dismissWindow()
            }
        }
        .padding(10)
    }

    func hoverContent() -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            Button {
                dismissWindow()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.black, .white)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(10)
        }
        .transition(.opacity)
    }

    var animation: Animation {
        .smooth(duration: 0.3, extraBounce: 0)
    }
}

struct DragDropDemoView: View {
    @Environment(\.openWindow) var openWindow
    let imageName: String = "fox"
    var body: some View {
        VStack {
            Button("Export \(imageName) Image") {
                exportImage(.init(named: imageName), compression: 0.5, fileName: "FOX-IMAGE")
            }
        }
    }

    func exportImage(_ image: NSImage?, compression: Float, fileName: String) {
        guard let image, let imageData = image.tiffRepresentation(using: .jpeg, factor: compression) else {
            return
        }

        let directroyPath = NSTemporaryDirectory().appending("\(fileName).jpg")
        let fileURL = URL(filePath: directroyPath)
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: directroyPath) {
            try? fileManager.removeItem(at: fileURL)
        }

        /// saving new file
        try? imageData.write(to: fileURL)
        openWindow(id: "PREVIEWWINDOW", value: fileURL)
    }
}

#Preview {
    DragDropDemoView()
}

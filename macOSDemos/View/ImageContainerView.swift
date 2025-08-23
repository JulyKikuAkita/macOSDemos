//
//  ImageContainerView.swift
//  macOSDemos
//

import SwiftUI
@available(macOS 26.0, *)
struct ImageContainerView: View {
    @State private var imageFiles: [ImageFile] = sampleItems
    @State private var selection: [ImageFile] = []
    @State private var dragRect: CGRect?
    @GestureState private var isActive: Bool = false

    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 5), spacing: 15) {
                ForEach(imageFiles) {
                    ImageFileGridRowView(
                        file: $0,
                        selection: $selection,
                        drawRect: $dragRect
                    )
                }
            }
            .padding(15)
        }
        .dragContainer(for: ImageFile.self) { draggedItemIDs in
            /// Checking if the currently dragged items in in the selection
            if selection.contains(where: { draggedItemIDs.contains($0.id) }) {
                return selection
            } else {
                /// Updating the selection to have the currently dragging id
                if let firstItemID = draggedItemIDs.first, let file = imageFiles.first(
                    where: { $0.id == firstItemID }) {
                    selection = [file]
                } else {
                    /// Empty selection, in case the dragging item is not found on the imageFiles
                    selection = []
                }
            }
            return selection
        }
        .dragPreviewsFormation(.pile)
        .onDragSessionUpdated { session in
            let phase = session.phase
            switch phase {
            case .active, .initial: print("Drag started")
            case .ended(let operation): onDrop(operation)
            default: ()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if let dragRect, isActive {
                Rectangle()
                    .fill(.blue.opacity(0.3))
                    .frame(width: dragRect.width, height: dragRect.height)
                    .position(x: dragRect.midX, y: dragRect.midY)
                    .allowsTightening(false)
            }
        }
        .onTapGesture {
            selection = []
        }
        .gesture(
            DragGesture(coordinateSpace: .named("FOLDERVIEW"))
                .updating($isActive, body: { _,out,_ in
                    out = true
                })
                .onChanged { value in
                    calculateRect(value: value)
                }.onEnded { value in
                    dragRect = nil
                }
        )
        .onChange(of: isActive, { oldValue, newValue in
            if isActive {
                /// Clearning out the previous selection
                selection = []
            }
        })
        .coordinateSpace(.named("FOLDERVIEW"))
    }

    private func onDrop(_ operation: DropOperation) {
        if operation == .delete {
            withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                imageFiles.removeAll { file in
                    selection.contains(where: { $0.id == file.id })
                }
            }
        }
    }

    private func calculateRect(value: DragGesture.Value) {
        let location = value.location
        let startLocation = value.startLocation

        dragRect = CGRect(
            x: min(startLocation.x, location.x),
            y: min(startLocation.y, location.y),
            width: abs(location.x - startLocation.x),
            height: abs(location.y - startLocation.y)
        )
    }
}

@available(macOS 26.0, *)
struct ImageFileGridRowView: View {
    var file: ImageFile
    @Binding var selection: [ImageFile]
    @Namespace private var FOLDERVIEW
    @Binding var drawRect: CGRect?
    /// View Properties
    @State private var viewLocation: CGRect = .zero
    var body: some View {
        VStack(spacing: 6) {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .overlay {
                    if let image = file.image {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .contentShape(.rect)
                .draggable(containerItemID: file.id, containerNamespace: FOLDERVIEW)

            Text(file.title)
                .font(.caption2)
                .foregroundStyle(.primary.secondary)
                .lineLimit(1)
        }
        .background {
            if selection.contains(where: { $0.id == file.id }) {
                Rectangle()
                    .fill(Color.primary.opacity(0.15))
                    .padding(-5)
            }
        }
        /// Adding file to the selection, if command + clicked
        .gesture(
            TapGesture().modifiers(.command).onEnded { _ in
                updateSelection()
            }
        )
        /// Normal tap gesture will remove the existing selection if the pressed file is not in [selection]
        .onTapGesture {
            if !selection.contains(where: { $0.id == file.id }) {
                selection = [file]
            }
        }
        .onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named("FOLDERVIEW"))
        } action: { newValue in
            viewLocation = newValue
        }
        .onChange(of: drawRect) { oldValue, newValue in
            guard let drawRect else { return }
            /// Checking if the drawRect is lies in the view location, if so adding the file to the selection
            if viewLocation.intersects(drawRect) {
                insertFile()
            } else {
                removeFile()
            }
        }
    }

    private func insertFile() {
        guard !selection.contains(where: { $0.id == file.id }) else { return }
        selection.append(file)
    }

    private func removeFile() {
        selection.removeAll(where: { $0.id == file.id })
    }

    private func updateSelection() {
        if selection.contains(where: { $0.id == file.id }) {
            removeFile()
        } else {
            insertFile()
        }
    }
}

@available(macOS 26.0, *)
#Preview {
    ImageContainerView()
}

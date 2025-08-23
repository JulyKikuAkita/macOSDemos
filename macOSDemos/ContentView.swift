//
//  ContentView.swift
//  macOSDemos
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            if #available(macOS 26.0, *) {
                ImageContainerView()
                    .navigationTitle("Untitled Folder")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Search", systemImage: "magnifyingglass") {
    
                            }
                        }
                        ToolbarItem(placement: .navigation) {
                            HStack(spacing: 0) {
                                Button("Back", systemImage: "chevron.left") {
    
                                }
    
                                Button(
                                    "Forward",
                                    systemImage: "chevron.right"
                                ) {
    
                                }
                            }
                        }
                    }
            } else {
                Text("Hello World")
            }
        }
    }
}

#Preview {
    ContentView()
}

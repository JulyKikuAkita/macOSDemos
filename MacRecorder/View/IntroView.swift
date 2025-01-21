//
//  IntroView.swift
//  MacRecorder
//

import SwiftUI

struct IntroView: View {
    @AppStorage("isUserIntroCompleted") private var isUserIntroCompleted: Bool = false
    @Environment(\.dismissWindow) private var dismissWindow
    var body: some View {
        VStack(spacing: 15) {
            Text("What's New in \nMac Recorder")
                .font(.system(size: 35, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 35)
            
            /// Points
            VStack(alignment: .leading, spacing: 25) {
                PointView(
                    title: "Record Screen",
                    image: "video.fill",
                    description: "Capture your screen with high-quality recordings."
                )
                PointView(
                    title: "Select Window",
                    image: "macwindow",
                    description: "Easily select any window for focused recording using ScreenCaptureKit."
                )
                PointView(
                    title: "Save Recording",
                    image: "folder.fill",
                    description: "Save your recordings to your desired location with a click."
                )
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 60)
            
            /// Continue/Quit Button
            HStack(spacing: 10) {
                Button {
                    /// Closing App
                    NSApplication.shared.terminate(nil)
                } label: {
                    Text("Quit App")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.red.gradient, in: .rect(cornerRadius: 8))
                }
                
                Button {
                    isUserIntroCompleted = true
                    /// Closing current window
                    dismissWindow(id: "IntroView")
                } label: {
                    Text("Start Using Mac Recorder")
                        .fontWeight(.bold)
                        .foregroundStyle(.background)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.primary.gradient, in: .rect(cornerRadius: 8))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(30)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 15))
        .gesture(WindowDragGesture())
    }
    
    /// Point View
    @ViewBuilder
    func PointView(title: String, image: String, description: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: image)
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .frame(width: 35)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
        }
    }
}

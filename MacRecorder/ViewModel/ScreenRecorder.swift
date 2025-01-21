//
//  ScreenRecorder.swift
//  MacRecorder
//
import SwiftUI
import ScreenCaptureKit /// new api from iOS 18

@MainActor
class ScreenRecorder: NSObject, ObservableObject, @preconcurrency SCContentSharingPickerObserver {
    override init() {
        super.init()
        setupWindowPicker()
    }
    
    /// View Properties
    @Published var showsCursor: Bool = true
    @Published var capturesAudio: Bool = true
    @Published var backgroundColor: Color = .white
    @Published var videoScale: VideoScale = .normal
    @Published var isRecording: Bool = false
    
    /// Private Properties
    private var contentFilter: SCContentFilter?
    private var stream: SCStream?
    private var streamOutput = StreamOutput()
    
    private func setupAndRecordWindow(_ url: URL) async throws {
        guard let contentFilter else { return }
        
        let configuration = SCStreamConfiguration()
        configuration.showsCursor = showsCursor
        configuration.capturesAudio = capturesAudio
        /// some color, including .white is not working on screen-capture-kit
        configuration.backgroundColor = backgroundColor == .white ? .white : NSColor(backgroundColor).cgColor
        
        let scale = CGFloat(videoScale.rawValue)
        let scaledVideoSize = contentFilter.contentRect.size.applying(.init(scaleX: scale, y: scale))
        configuration.width = Int(scaledVideoSize.width)
        configuration.height = Int(scaledVideoSize.height)
        configuration.scalesToFit = true
        
        let stream = SCStream(filter: contentFilter, configuration: configuration, delegate: streamOutput)
        try stream.addStreamOutput(streamOutput, type: .audio, sampleHandlerQueue: nil)
        try stream.addStreamOutput(streamOutput, type: .screen, sampleHandlerQueue: nil)
        
        let outputConfiguration = SCRecordingOutputConfiguration()
        outputConfiguration.outputURL = url
        outputConfiguration.outputFileType = .mov
        
        let output = SCRecordingOutput(configuration: outputConfiguration, delegate: streamOutput)
        try stream.addRecordingOutput(output)
        
        /// Starting Capture
        try await stream.startCapture()
        
        self.isRecording = true
        self.stream = stream
        
        streamOutput.finishRecording = {
            /// update UI back to main thread
            Task {
                do {
                    try await stream.stopCapture()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func stopWindowRecording() {
        Task { @MainActor in
            self.stream = nil
            self.contentFilter = nil
            self.isRecording = false
        }
    }
        
    private func askFileLocation() {
        Task {
            do {
                let panel = NSOpenPanel()
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                panel.allowsMultipleSelection = false
                panel.showsHiddenFiles = false
                
                let response = panel.runModal()
                if response == .OK {
                    if let fileURL = panel.url?.appending(path: "Recording \(Date()).mov") {
                        try await setupAndRecordWindow(fileURL)
                    }
                }
            } catch {
                /// Handling Errors
                print(error.localizedDescription)
            }
        }
    }
}

/// Setting Up new window picker by screen-capture-kit
extension ScreenRecorder {
    func setupWindowPicker() {
        var pickerConfiguration = SCContentSharingPickerConfiguration()
        pickerConfiguration.allowedPickerModes = .singleWindow
        pickerConfiguration.allowsChangingSelectedContent = false
        
        SCContentSharingPicker.shared.configuration = pickerConfiguration
        SCContentSharingPicker.shared.add(self)
    }
    
    func contentSharingPicker(_ picker: SCContentSharingPicker, didCancelFor stream: SCStream?) {
        SCContentSharingPicker.shared.isActive = false
    }
    
    func contentSharingPicker(_ picker: SCContentSharingPicker, didUpdateWith filter: SCContentFilter, for stream: SCStream?) {
        /// the window has been selected and we can proceed to close the picker view, ask the file location for the recording to be saved
        SCContentSharingPicker.shared.isActive = false
        askFileLocation()
    }
    
    func contentSharingPickerStartDidFailWithError(_ picker: SCContentSharingPicker, error: Error) {
        /// Handle Error
    }
    
    func contentSharingPickerStartDidFailWithError(_ error: any Error) {
    }
}

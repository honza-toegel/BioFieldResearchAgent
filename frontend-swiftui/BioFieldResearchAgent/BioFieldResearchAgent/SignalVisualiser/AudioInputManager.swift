//
//  AudioInputManager.swift
//  BioFieldResearchAgent
//
//  Created by Jan Toegel on 18.04.2025.
//

import AVFoundation
import SwiftUICore

class AudioInputManager : ObservableObject {
    @Published var signalDownsampleProcessor: SignalDownsampleProcessor = SignalDownsampleProcessor(circularBufferSize: 1024, downsamplingRate: 5, downsamplingMode: DownsamplingMode.peak)
    @Published var frequencySpectrumProcessor: FrequencySpectrumProcessor = FrequencySpectrumProcessor(bufferSize: 2048)
    
    private let engine = AVAudioEngine()
    var onAmplitudeUpdate: ((Float) -> Void)?

    init() {
        configureAudioSession()

        let inputNode = engine.inputNode
        let format = inputNode.inputFormat(forBus: 0)

        // Optional: Defensive check
        guard format.channelCount > 0 else {
            print("Audio format has zero channels — cannot install tap.")
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 2048, format: format) { buffer, _ in
            // Preprocess amplitude updates for simple views
            let level = self.computeAmplitude(buffer: buffer)
            print("Amplitude: \(level)")
            DispatchQueue.main.async {
                self.onAmplitudeUpdate?(level)
                
            }
            
            guard let floatChannelSignalData = buffer.floatChannelData else { return }
            let signalDataLenght = Int(buffer.frameLength)
            let monoChannelSignalData: UnsafeMutablePointer = floatChannelSignalData[0] // mono
            let monoChannelBuffer: UnsafeBufferPointer = UnsafeBufferPointer(start: monoChannelSignalData, count: signalDataLenght)
            
            let clippedMonoChannelBuffer: UnsafeBufferPointer = UnsafeBufferPointer(start: monoChannelSignalData, count: 2048)
            
            // Overhand raw audio data, iOS already normalized for osciloscope rendering [0..1]
            self.signalDownsampleProcessor.processIncomingAudioBuffer(monoChannelBuffer)
            self.frequencySpectrumProcessor.processIncomingAudioBuffer(clippedMonoChannelBuffer)
        }

        do {
            try engine.start()
        } catch {
            print("❌ Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    func configureCicularBuffer(circularBufferSize: Int, downsamplingRate: Int, downsamplingMode: DownsamplingMode) {
        signalDownsampleProcessor = SignalDownsampleProcessor(circularBufferSize: circularBufferSize, downsamplingRate: downsamplingRate, downsamplingMode: downsamplingMode)
    }

    #if os(iOS)
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            print("🎤 Microphone initialised.")
        } catch {
            print("⚠️ Error setting up audio session: \(error)")
        }
    }
    #elseif os(macOS)
    private func configureAudioSession() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            if granted {
                print("🎤 Microphone access granted.")
            } else {
                print("⚠️ Microphone access denied.")
            }
        }
    }
    #endif
    
    private var smoothedAmplitude: Float = 0
    private let smoothingFactor: Float = 0.3  // tweak between 0.1 (slow) and 0.3 (responsive)

    private func computeAmplitude(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }

        let frameLength = Int(buffer.frameLength)
        let channelDataPointer = UnsafeBufferPointer(start: channelData, count: frameLength)

        let rms = sqrt(channelDataPointer.reduce(0) { $0 + $1 * $1 } / Float(frameLength))
        let rawAmplitude = min(max(rms * 20, 0), 1)

        // 🔥 Apply smoothing
        smoothedAmplitude = smoothedAmplitude * (1 - smoothingFactor) + rawAmplitude * smoothingFactor

        return smoothedAmplitude
    }

}

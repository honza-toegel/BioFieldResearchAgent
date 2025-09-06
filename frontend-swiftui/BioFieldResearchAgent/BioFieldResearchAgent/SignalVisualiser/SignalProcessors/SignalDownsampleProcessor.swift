//
//  AudioCircularBuffer.swift
//  BioFieldResearchAgent
//
//  Created by Jan Toegel on 04.05.2025.
//

import AVFoundation

enum DownsamplingMode : String, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case peak
    case average
    case first
}

// Desired work of SignalDownsampleProcessor
// It process incoming updates of signal data of producer
//       example - 44kHz mono audio are in iOS/macOS blocks of data 4800 values
// It downsample directly those data and store them internally
// It provides downsampled data to the consumers (Rendering pipeline 60fps)
// It guarante that the consumer gets allways the whole buffer (not cutted by parallel writing of new data)

class SignalDownsampleProcessor : ObservableObject, SignalProcessor {
    private let bufferSize: Int
    private let downsamplingRate: Int
    private let downsamplingMode: DownsamplingMode
    
    private let bufferQueue = DispatchQueue(label: "signal.queue.synchronization")
    private var signalQueue = Array<Float>()
    
    
    init(bufferSize: Int, downsamplingRate: Int = 1, downsamplingMode: DownsamplingMode = .peak) {
        self.bufferSize = bufferSize
        self.downsamplingRate = downsamplingRate
        self.downsamplingMode = downsamplingMode
        self.signalQueue.append(contentsOf: repeatElement(0.0, count: bufferSize))
    }
    
    func processIncomingAudioBuffer(_ signalDataBuffer: UnsafeBufferPointer<Float>) {
        let batchCount = signalDataBuffer.count / downsamplingRate
        guard batchCount > 0 else { return }
        guard let signalDataPointer = signalDataBuffer.baseAddress else { return }

        var downsampledValues = [Float](repeating: 0.0, count: batchCount)

        DispatchQueue.concurrentPerform(iterations: batchCount) { batchIndex in
            let framePosition = batchIndex * downsamplingRate
            let sliceLength = min(downsamplingRate, signalDataBuffer.count - framePosition)
            let slice = UnsafeBufferPointer(start: signalDataPointer + framePosition, count: sliceLength)
            
            switch downsamplingMode {
            case .first:
                downsampledValues[batchIndex] = slice[0]
            case .average:
                downsampledValues[batchIndex] = slice.reduce(0, +) / Float(slice.count)
            case .peak:
                let maxVal = slice.max() ?? 0
                let minVal = slice.min() ?? 0
                downsampledValues[batchIndex] = abs(maxVal) > abs(minVal) ? maxVal : minVal
            }
        }

        bufferQueue.sync {
            signalQueue.append(contentsOf: downsampledValues)
            if (signalQueue.count > bufferSize) {
                signalQueue.removeFirst(signalQueue.count - bufferSize)
            }
        }
    }

    func getCurrentBuffer() -> [Float] {
        return bufferQueue.sync {
            return signalQueue
        }
    }
}

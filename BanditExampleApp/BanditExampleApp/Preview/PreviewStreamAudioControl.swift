/*
 * Copyright (C) 2012-2016. TomTom International BV (http://tomtom.com).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import BanditCameraKit
import AudioToolbox

class PreviewStreamAudioControl {

    var previewBuffer: PreviewStreamBuffer!
    
    private let defaultSampleRate: Float64 = 48000
    private let audioQueueBufferSize: UInt32 = 4000
    private let numberOfAudioQueueBuffers: Int = 3
    private let adtsHeaderSizeInBytes: Int = 7
    private let checkPreviewBufferInterval: NSTimeInterval = 0.3
    private var streamDescription: AudioStreamBasicDescription = AudioStreamBasicDescription()
    private var audioQueue: AudioQueueRef = nil
    private var audioQueueBuffers: [AudioQueueBufferRef]
    private var playing: Bool = false
    private var unbufferedFrame: NSData!
    
    init() {
        streamDescription.mSampleRate = defaultSampleRate
        streamDescription.mFormatID = kAudioFormatMPEG4AAC
        streamDescription.mFormatFlags = 0
        streamDescription.mBytesPerPacket = 0
        streamDescription.mFramesPerPacket = 1024
        streamDescription.mBytesPerFrame = 0
        streamDescription.mChannelsPerFrame = 1
        streamDescription.mBitsPerChannel = 0
        streamDescription.mReserved = 0

        audioQueueBuffers = [AudioQueueBufferRef](count: numberOfAudioQueueBuffers, repeatedValue: nil)
    }
    
    func initialize(sampleRateModifier: Float64 = 1) {
        streamDescription.mSampleRate = defaultSampleRate * sampleRateModifier
        let weakSelf = UnsafeMutablePointer<Void>(Unmanaged.passUnretained(self).toOpaque())
        var status = AudioQueueNewOutput(&streamDescription, audioQueueOutputCallback, weakSelf, nil, nil, 0, &audioQueue)
        if status != kAudioServicesNoError {
            log.error("Failed to initialize audio, status code: \(status)")
            return
        }
        for index in 0..<numberOfAudioQueueBuffers {
            status = AudioQueueAllocateBuffer(audioQueue, audioQueueBufferSize, &audioQueueBuffers[index])
            if status != kAudioServicesNoError {
                log.error("Failed to allocate audio buffer \(index), status code: \(status)")
                return
            }
            audioQueueBuffers[index].memory.mAudioDataByteSize = audioQueueBufferSize
        }
        AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1)
    }
    
    func start(withInitialBufferEnqueue enqueue: Bool = true) {
        if playing == false {
            playing = true
            dispatch_async(dispatch_get_main_queue()) {
                if enqueue {
                    for buffer in self.audioQueueBuffers {
                        self.audioQueueCallback(self.audioQueue, buffer)
                    }
                }
                let status = AudioQueueStart(self.audioQueue, nil)
                if status != kAudioServicesNoError {
                    log.error("Failed to start audio, status code: \(status)")
                }
            }
        }
    }
    
    func stop() {
        if playing {
            playing = false
            var status = AudioQueueStop(audioQueue, true)
            if status == kAudioServicesNoError {
                status = AudioQueueReset(audioQueue)
                if status != kAudioServicesNoError {
                    log.error("Failed to reset audio queue, status code: \(status)")
                }
            }
            else {
                log.error("Failed to stop audio, status code: \(status)")
            }
            audioQueue = nil
        }
    }
    
    func pause() {
        if playing {
            playing = false
            let status = AudioQueuePause(audioQueue)
            if status != kAudioServicesNoError {
                log.error("Failed to pause audio, status code: \(status)")
            }
        }
        else {
            start(withInitialBufferEnqueue: false)
        }
    }

    private func audioQueueCallback(queue: AudioQueueRef, _ buffer: AudioQueueBufferRef) {
        if playing == false {
            return
        }

        var audioPackets: [AudioStreamPacketDescription] = []
        let dataToCopy: NSMutableData = NSMutableData()

        if let unbufferedFrame = unbufferedFrame {
            self.addAudioStreamPacketDescription(unbufferedFrame, allFrames: dataToCopy, audioPackets: &audioPackets)
            self.unbufferedFrame = nil
        }
        
        getNextFrame(queue, buffer: buffer, dataToCopy: dataToCopy, audioPackets: &audioPackets)
        
        if dataToCopy.length > 0 {
            memcpy(buffer.memory.mAudioData, dataToCopy.bytes, dataToCopy.length)
            AudioQueueEnqueueBuffer(queue, buffer, UInt32(audioPackets.count), UnsafePointer<AudioStreamPacketDescription>(audioPackets))
        }
        else {
            let interval = dispatch_time(DISPATCH_TIME_NOW, Int64(self.checkPreviewBufferInterval * Double(NSEC_PER_SEC)))
            dispatch_after(interval, dispatch_get_main_queue()) {
                self.audioQueueCallback(queue, buffer)
            }
        }
    }
    
    private func getNextFrame(queue: AudioQueueRef, buffer: AudioQueueBufferRef, dataToCopy: NSMutableData, inout audioPackets: [AudioStreamPacketDescription]) {
        
        previewBuffer.getNextAudioFrame { (frameData, presentationTimestamp) in
            guard let frameData = frameData else {
                return
            }

            let actualFrame = self.removeADTSHeader(frameData)
            if dataToCopy.length + actualFrame.length < Int(self.audioQueueBufferSize) {
                self.addAudioStreamPacketDescription(actualFrame, allFrames: dataToCopy, audioPackets: &audioPackets)
                self.getNextFrame(queue, buffer: buffer, dataToCopy: dataToCopy, audioPackets: &audioPackets)
            }
            else {
                self.unbufferedFrame = actualFrame
            }
        }
    }

    private func addAudioStreamPacketDescription(frame: NSData, allFrames: NSMutableData, inout audioPackets: [AudioStreamPacketDescription]) {
        var audioPacket: AudioStreamPacketDescription = AudioStreamPacketDescription()
        audioPacket.mVariableFramesInPacket = 1
        audioPacket.mDataByteSize = UInt32(frame.length)
        audioPacket.mStartOffset = Int64(allFrames.length)
        audioPackets.append(audioPacket)
        allFrames.appendData(frame)
    }
    
    private func removeADTSHeader(data: NSData) -> NSData {
        let actualLength = data.length - adtsHeaderSizeInBytes
        return data.subdataWithRange(NSMakeRange(adtsHeaderSizeInBytes, actualLength))
    }

    private let audioQueueOutputCallback: AudioQueueOutputCallback = { (userData, queue, buffer) in
        let audioControl: PreviewStreamAudioControl = Unmanaged<PreviewStreamAudioControl>.fromOpaque(COpaquePointer(userData)).takeUnretainedValue()
        audioControl.audioQueueCallback(queue, buffer)
    }
}

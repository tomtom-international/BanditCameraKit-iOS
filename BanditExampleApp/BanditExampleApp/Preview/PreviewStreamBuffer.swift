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

import BanditCameraKit

struct Frame {
    var data: NSData!
    var presentationTimestamp: UInt32 = 0
}

public class PreviewStreamBuffer {

    var delegate: PreviewStreamBufferDelegate?
    var writeEnabled: Bool = true
    var minimumNumberOfVideoFrames: Int = 30
    var hasDataForReading: Bool {
        return videoBuffer.canRead || audioBuffer.canRead
    }

    private let videoBufferMaxFrames: Int = 2000
    private let audioBufferMaxFrames: Int = 8000
    private let tryToWriteDataToBufferInterval: NSTimeInterval = 0.3
    private var videoBuffer: CircularBuffer<Frame>
    private var audioBuffer: CircularBuffer<Frame>
    
    public init() {
        videoBuffer = CircularBuffer<Frame>(count: videoBufferMaxFrames)
        audioBuffer = CircularBuffer<Frame>(count: audioBufferMaxFrames)
    }

    public func clear() {
        writeEnabled = false
        videoBuffer.clear()
        audioBuffer.clear()
    }
    
    public func getNextVideoFrame(completion: (frameData: NSData?, presentationTimestamp: UInt32) -> Void) {
        getNextFrame(videoBuffer, completion: completion)
    }

    public func getNextAudioFrame(completion: (frameData: NSData?, presentationTimestamp: UInt32) -> Void) {
        getNextFrame(audioBuffer, completion: completion)
    }

    private func getNextFrame(buffer: CircularBuffer<Frame>, completion: (frameData: NSData?, presentationTimestamp: UInt32) -> Void) {
        guard let frame = buffer.read() else {
            completion(frameData: nil, presentationTimestamp: 0)
            return
        }
        
        completion(frameData: frame.data, presentationTimestamp: frame.presentationTimestamp)
    }
    
    private func tryToWrite(frame: Frame, toBuffer buffer: CircularBuffer<Frame>) {
        if buffer.write(frame) == false {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(tryToWriteDataToBufferInterval * Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.tryToWrite(frame, toBuffer: buffer)
            }
        }
    }
}

extension PreviewStreamBuffer: PreviewStreamReceiverBufferDelegate {
    
    public func previewVideoFrameReceived(frame: NSData, forPresentationTimeStamp pts: UInt32) {
        let frame = Frame(data: frame, presentationTimestamp: pts)
        tryToWrite(frame, toBuffer: videoBuffer)
        if videoBuffer.writingIndex == minimumNumberOfVideoFrames {
            delegate?.minimumNumberOfVideoFramesReached()
        }
    }
    
    public func previewAudioFrameReceived(frame: NSData, forPresentationTimeStamp pts: UInt32) {
        let frame = Frame(data: frame, presentationTimestamp: pts)
        tryToWrite(frame, toBuffer: audioBuffer)
    }
    
    public func previewSafeToReadMoreData() -> Bool {
        return videoBuffer.canWrite && audioBuffer.canWrite && writeEnabled
    }
}

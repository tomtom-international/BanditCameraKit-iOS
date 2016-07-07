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

/// Preview stream receiver buffer delegate
public protocol PreviewStreamReceiverBufferDelegate : class {
    /**
     Notifies the buffer that new video frame has been received
     
     - parameter frame: Video frame data
     - parameter pts:   Video frame presentation timestamp
     */
    func previewVideoFrameReceived(frame: NSData, forPresentationTimeStamp pts: UInt32)
    
    /**
     Notifies the buffer that new audio frame has been received
     
     - parameter frame: Audio frame data
     - parameter pts:   Audio frame presentation timestamp
     */
    func previewAudioFrameReceived(frame: NSData, forPresentationTimeStamp pts: UInt32)
    
    /**
     Receiver calls this function to check if reading from the socket can continue or needs to be put on hold
     
     - returns: true if buffer is not full and can receive more frames, false if buffer is full
     */
    func previewSafeToReadMoreData() -> Bool
}

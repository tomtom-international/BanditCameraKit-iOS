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

class PreviewStreamControl {
    
    var delegate: PreviewStreamControlDelegate?
    var previewReceiver: PreviewStreamReceiver!
    var buffer: PreviewStreamBuffer = PreviewStreamBuffer()
    var videoControl: PreviewStreamVideoControl = PreviewStreamVideoControl()
    var audioControl: PreviewStreamAudioControl = PreviewStreamAudioControl()

    private let ptsDivider: UInt32 = 90
    private var currentPreviewMediaItem: MediaItem? = nil
    private var endOfStreamReceived: Bool = false
    private var previewDidStartCompletionBlock: (() -> Void)? = nil
    
    init() {
        previewReceiver = PreviewStreamReceiver(stateDelegate: self, bufferDelegate: buffer)
        previewReceiver.start()
        buffer.delegate = self
        videoControl.sendNewVideoFrameBlock = {
            self.sendNewVideoFrame()
        }
        audioControl.previewBuffer = buffer
    }

    deinit {
        previewReceiver.stop()
    }
    
    func startPreviewFor(mediaItem: MediaItem, _ completion: (() -> Void)? = nil) {
        endOfStreamReceived = false
        previewDidStartCompletionBlock = completion

        stop {
            self.setupForMediaItem(mediaItem)
            self.currentPreviewMediaItem = mediaItem
            self.sendStartPreviewFor(mediaItem)
        }
    }
    
    func pause() {
        videoControl.pause()
        audioControl.pause()
        delegate?.previewDidPause(videoControl.paused)
    }
    
    func stop(completion: (() -> Void)? = nil) {
        videoControl.stop()
        audioControl.stop()
        buffer.clear()
        
        if let currentPreviewMediaItem = currentPreviewMediaItem {
            sendStopPreviewFor(currentPreviewMediaItem, completion)
            self.currentPreviewMediaItem = nil
        }
        else {
            completion?()
            notifyPreviewDidStop()
        }
    }
    
    private func start() {
        videoControl.start()
        audioControl.start()
        delegate?.previewDidStart()
    }
    
    private func sendStartPreviewFor(mediaItem: MediaItem, _ completion: (() -> Void)? = nil) {
        camera.rest.startPreview(mediaItem.mediaItemId, previewPort: previewReceiver.listeningPort) {
            self.buffer.writeEnabled = true
            completion?()
        }.failure { (response, error) in
            completion?()
        }
    }

    private func sendStopPreviewFor(mediaItem: MediaItem, _ completion: (() -> Void)? = nil) {
        camera.rest.stopPreview(mediaItem.mediaItemId, previewPort: previewReceiver.listeningPort) {
            completion?()
            self.notifyPreviewDidStop()
        }.failure { (response, error) in
            completion?()
            self.notifyPreviewDidStop()
        }
    }

    private func sendNewVideoFrame() {
        buffer.getNextVideoFrame { (frameData, presentationTimestamp) in
            if self.endOfStreamReceived && self.buffer.hasDataForReading == false {
                self.stop()
                return
            }
            guard let delegate = self.delegate else {
                return
            }
            guard let frameData = frameData else {
                return
            }
            guard let frame = UIImage(data: frameData) else {
                return
            }
            
            let pts = Double(presentationTimestamp / self.ptsDivider)
            dispatch_async(dispatch_get_main_queue()) {
                delegate.previewShouldPresentVideoFrame(frame, forPresentationTimestamp: pts)
            }
        }
    }
    
    private func setupForMediaItem(mediaItem: MediaItem) {
        if mediaItem is VideoItem {
            let video = mediaItem as! VideoItem
            videoControl.setFramerate(video.previewFramerate)
            audioControl.initialize(1 / Float64(video.slowDownRate))
        }
    }
    
    private func notifyPreviewDidStop() {
        previewReceiver.stopReceiving()
        delegate?.previewDidStop()
    }
}

extension PreviewStreamControl: PreviewStreamBufferDelegate {
    
    func minimumNumberOfVideoFramesReached() {
        start()
        previewDidStartCompletionBlock?()
    }
}

extension PreviewStreamControl: PreviewStreamReceiverStateDelegate {

    func previewDidConnect() {
        log.debug("Preview receiver connected")
    }
    
    func previewDidDisconnect() {
        log.debug("Preview receiver disconnected")
    }
    
    func previewStartOfStreamReceived() {
        log.debug("Start of stream received")
    }
    
    func previewEndOfStreamReceived() {
        endOfStreamReceived = true
        log.debug("End of stream received")
    }
}

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

class PreviewStreamVideoControl {

    var sendNewVideoFrameBlock: (() -> Void)? = nil
    var paused: Bool {
        return displayLink.paused
    }
    
    private let maxFramerate: Double = 30
    private let maxDeviceFramerate: Double = 60
    private var displayLink: CADisplayLink!
    
    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(PreviewStreamVideoControl.sendNewVideoFrame))
        displayLink.frameInterval = Int(maxDeviceFramerate / maxFramerate)
        displayLink.paused = true
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func setFramerate(framerate: Double) {
        displayLink.frameInterval = Int(maxDeviceFramerate / min(framerate, maxFramerate))
    }
    
    func start() {
        displayLink.paused = false
    }

    func stop() {
        displayLink.paused = true
    }

    func pause() {
        displayLink.paused = !displayLink.paused
    }
    
    @objc private func sendNewVideoFrame() {
        if let sendNewVideoFrameBlock = sendNewVideoFrameBlock {
            sendNewVideoFrameBlock()
        }
    }
}

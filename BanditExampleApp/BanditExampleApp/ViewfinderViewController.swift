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

class ViewfinderViewController: BaseViewController, ViewfinderStreamDelegate {

    let viewfinderPort: UInt16 = 4001
    var viewfinderStream: ViewfinderStream!
    @IBOutlet var imageViewViewfinder: UIImageView!
    @IBOutlet var buttonRecording: UIButton!
    @IBOutlet var labelRecording: UILabel!
    @IBOutlet var segmentRecordingMode: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        viewfinderStream = ViewfinderStream(delegate: self)
    }

    deinit {
        stopViewfinder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if camera.connected {
            startViewfinder()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if camera.connected {
            stopViewfinder()
        }
    }

    override func onCameraConnected(completion: (() -> Void)? = nil) {
        super.onCameraConnected() {
            if camera.status.recordingActive {
                self.onRecordingStarted()
            }
            self.startViewfinder()
            completion?()
        }
    }

    func onRecordingStarted() {
        camera.status.recordingActive = true
        self.buttonRecording.setTitle("Stop", forState: UIControlState.Normal)
        self.buttonRecording.enabled = true
        log.info("Recording started")
    }
    
    func onRecordingStopped() {
        camera.status.recordingActive = false
        self.labelRecording.text = ""
        self.buttonRecording.setTitle("Record", forState: UIControlState.Normal)
        self.buttonRecording.enabled = true
        log.info("Recording stopped")
    }
    
    @IBAction func toggleRecording() {
        if camera.connected {
            if camera.recordingMode.type == .Video {
                buttonRecording.enabled = false
                if camera.status.recordingActive {
                    camera.rest.stopRecording({})
                }
                else {
                    camera.rest.startRecording({})
                }
            }
            else {
                camera.rest.startRecording({})
            }
        }
    }
    
    @IBAction func switchRecordingMode() {
        if camera.connected {
            if segmentRecordingMode.selectedSegmentIndex == 0 {
                setVideoMode()
            }
            else {
                setImageMode()
            }
        }
    }
    
    func frameReceived(frame: NSData) {
        if let image = UIImage(data: frame) {
            dispatch_async(dispatch_get_main_queue()) {
                self.imageViewViewfinder.image = image
            }
        }
    }
    
    func presentationTimestampReceived(presentationTimestamp: Double) {
        if camera.status.recordingActive {
            labelRecording.text = String(format: "%.1f", presentationTimestamp)
        }
    }
    
    func startViewfinder() {
        viewfinderStream.start(onPort: self.viewfinderPort)
        camera.rest.startViewfinder(onPort: self.viewfinderPort) {
            log.info("Viewfinder started")
        }
    }
    
    func stopViewfinder() {
        camera.rest.stopViewfinder {
            self.viewfinderStream.stop()
            log.info("Viewfinder stopped")
        }
    }
    
    private func setVideoMode() {
        let videoMode = RecordingMode()
        videoMode.type = .Video
        videoMode.mode = .VideoNormal
        videoMode.resolution = .FHD_1080p
        videoMode.frameRate = 60
        videoMode.fieldOfView = .Wide
        startActivityIndicator()
        camera.rest.setVideoModeWithSettings(videoMode) {
            camera.recordingMode = videoMode
            self.stopActivityIndicator()
        }
    }

    private func setImageMode() {
        let imageMode = RecordingMode()
        imageMode.type = .Image
        imageMode.mode = .ImageSingle
        imageMode.resolution = .Image_16MP
        imageMode.fieldOfView = .Wide
        startActivityIndicator()
        camera.rest.setImageModeWithSettings(imageMode) {
            camera.recordingMode = imageMode
            self.stopActivityIndicator()
        }
    }
}

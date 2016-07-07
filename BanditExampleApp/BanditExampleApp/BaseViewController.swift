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

class BaseViewController: UIViewController {

    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let activityLabel: UILabel = UILabel()
    @IBOutlet var buttonConnect: UIButton!
    @IBOutlet var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addActivityIndicator()
        updateViewsHiddenState()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateViewsHiddenState()
    }
    
    @IBAction func connect() {
        startActivityIndicator("Connecting...")
        camera.rest.getAPIVersion { (version, revision) in
            self.stopActivityIndicator()
            self.onCameraConnected()
            }.failure { (response, error) in
                self.stopActivityIndicator()
                self.showAlert("Please go to WiFi Settings and connect your phone to TomTom Bandit WiFi")
        }
    }
    
    func startActivityIndicator(message: String? = nil) {
        if let tabBar = appDelegate.tabBar {
            tabBar.tabBar.userInteractionEnabled = false
        }
        if let message = message {
            activityLabel.text = message
        }
        activityIndicator.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        activityLabel.text = ""
        if let tabBar = appDelegate.tabBar {
            tabBar.tabBar.userInteractionEnabled = true
        }
    }

    func updateViewsHiddenState() {
        if let buttonConnect = buttonConnect {
            buttonConnect.hidden = camera.connected
        }
        if let containerView = containerView {
            containerView.hidden = !camera.connected
        }
    }
    
    func onCameraConnected(completion: (() -> Void)? = nil) {
        camera.connected = true
        updateStatus {
            appDelegate.backchannelNotificationStream.startOnHost(camera.rest.IPAddress, port: UInt16(camera.status.backchannelPort))
            self.updateViewsHiddenState()
            completion?()
        }
    }

    func onCameraDisconnected() {
        camera.connected = false
        updateViewsHiddenState()
    }
    
    func updateStatus(completion: (() -> Void)? = nil) {
        camera.rest.getStatus { (cameraStatus) in
            camera.status = cameraStatus
            completion?()
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func addActivityIndicator() {
        let screenBounds = UIScreen.mainScreen().bounds
        activityIndicator.frame = screenBounds
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.9)
        activityLabel.frame = CGRectMake(0, screenBounds.midY / 2, screenBounds.width, 64)
        activityLabel.font = UIFont.systemFontOfSize(20, weight: UIFontWeightLight)
        activityLabel.textColor = UIColor.whiteColor()
        activityLabel.textAlignment = NSTextAlignment.Center
        activityIndicator.addSubview(activityLabel)
        view.addSubview(activityIndicator)
    }
}

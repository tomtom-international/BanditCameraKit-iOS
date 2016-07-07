# BanditCameraKit-iOS

BanditCameraKit is a library for communication with the TomTom Bandit Action Camera's media server. The library is written in Swift and a detailed description of the camera media server API is available on the [Camera Media Server API](http://developer.tomtom.com/products/sports/cameramediaserver) pages. These pages contain not just the API specification but also more information about the video file, sensor data and tags format.

The library was created as a part of the TomTom Bandit mobile application project which is used as a mobile companion to [TomTom Bandit action camera](https://www.tomtom.com/en_gb/action-camera/action-camera/).

To get you started with the library quickly, there's an example project included which demos some of the basic features of the camera and the library.

We hope you'll have fun using it as much as we had creating it!


## Requirements

- iOS 8.0+ / Mac OS X 10.9+
- Xcode 7.3+
- CocoaPods 0.39+   

**NOTE:** In order to use the BanditCameraKit you need a TomTom Bandit Action Camera with firmware version 1.57.500 or newer.


## 3rd Party dependency

The BanditCameraKit relies on 3rd party libraries for communication with the camera.

- [Alamofire](https://github.com/Alamofire/Alamofire)
- [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)

Both are licensed under the MIT licence.


## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/banditcamera). (Tag 'banditcamera')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/banditcamera).
- If you've **found a bug** get back to us at <developersupport.camera@tomtom.com>


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it by using following command:

```bash
$ gem install cocoapods
```
To integrate the BanditCameraKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'BanditCameraKit'
end
```

Then, run the following command:

```bash
$ pod install
```

### Manual install

If you prefer not to use dependency managers, you can integrate the BanditCameraKit into your project manually. Just include files in your project.


## Usage

The BanditCameraKit covers all communication channels with the camera.

- REST
- Viewfinder stream
- Preview stream
- Backchannel notifications

To use the BanditCameraKit you need to import it using:

```swift
import BanditCameraKit
```

### REST

The REST layer of the BanditCameraKit uses [Alamofire](https://github.com/Alamofire/Alamofire) for executing HTTP calls. It is used to check current camera state, control the camera and to fetch resources from the camera. Each resource is defined in the Models section. By using our models you don't have to worry about serialisation and deserialisation of JSON responses. The complete list of HTTP calls is available on [Camera Media Server API](http://developer.tomtom.com/products/sports/cameramediaserver) pages.
In order to communicate with the camera's media server you have to create an instance of *CameraRESTClient* and initialise communication by calling getAPIVersion().

```swift
let restClient: CameraRESTClient = CameraRESTClient()
restClient.getAPIVersion { (version, revision) in
            // success -> communication initialized properly. You can continue.
            }.failure { (response, error) in
                //failure -> communication initialization failed. All REST calls will fail.
                }
```

*The camera's media server works on address ***192.168.1.101*** on port ***80***.*

You can find some examples on how to use the REST layer below:

#### Sample status call

```swift
restClient.getStatus { (cameraStatus) in
            // returns current camera status as described in CameraStatus model
        }
```

*As you can see failure closure is not mandatory. This is true for all REST calls.*

#### Changing video modes

```swift
let videoMode = RecordingMode()
// update videoMode object with desired mode settings
restClient.setVideoMode(videoMode) { (videoMode) in
        // returns new video mode
        }
```

 A list of supported modes is described in the Capabilities section of the [Camera Media Server API](http://developer.tomtom.com/products/sports/cameramediaserver/capabilities) and it's available over *getRecordingCapabilities()* call.

#### Downloading video files

To download a file you need to define the path where you want to save the file. In addition to success and failure closures you can track download progress in progress closure.

```swift
restClient.cameraRESTClient.downloadVideo("video-id", fileDestinationPath: "download-path").success { (path) in
            // path where file is saved
        }.progress { (progress) in
            // progress in percents
        }
```

### Viewfinder stream

The Viewfinder stream delivers JPGs at 30 frames per second. JPEG resolution is set to 768x432px. Images are delivered over UDP protocol. Together with the image, the camera sends the presentation timestamp (PTS) of each image. If recording is in progress the PTS matches the PTS of the frame in the recorded video. Otherwise PTS is **0**. The Viewfinder uses 4001 port as default port.

To receive images you need to implement *ViewfinderStreamDelegate* protocol and create a UDP connection using the *ViewfinderStream* class. The camera starts to send images over UDP as soon as the startViewfinder() REST call is invoked.

```swift
class ViewfinderViewController: ViewfinderStreamDelegate {

    let viewfinderPort: UInt16 = 4001
    var viewfinderStream: ViewfinderStream!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewfinderStream = ViewfinderStream(delegate: self)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewfinderStream.start(onPort: self.viewfinderPort) // starts UDP
        restClient.startViewfinder(onPort: self.viewfinderPort) {
            print("Viewfinder started") // tell camera to start sending
        }
    }

    deinit {
        restClient.stopViewfinder { // tell camera to stop sending
            self.viewfinderStream.stop() // stops UDP
            print("Viewfinder stopped")
        }
    }

    func frameReceived(frame: NSData) {
        if let image = UIImage(data: frame) {
            // use image for UI
        }
    }

    func presentationTimestampReceived(presentationTimestamp: Double) {
        // if recording is in progress presentationTimestamp != 0.0
    }
}
```

### Preview stream

The Preview stream receiver is used to start a client side server which receives video and audio frames from the camera for a requested video. Preview stream frames are delivered over TCP protocol which guarantees that no frames will be dropped. Each frame has its data and corresponding presentation timestamp.

*PreviewStreamReceiver* needs to be created and listening started. *PreviewStreamReceiver* needs a buffer to store the frames which is an object implementing the *PreviewStreamReceiverBufferDelegate*. Current preview connection status notifications, start of stream and end of stream are supported with *PreviewStreamReceiverStateDelegate*.
Examples of the preview stream buffer and preview control objects can be found in the *BanditExampleApp/Preview*.

```swift
...
private func startPreviewFor(video: VideoItem) {
    startActivityIndicator()
    previewControl.startPreviewFor(video) {
        self.stopActivityIndicator()
    }
}

@objc private func pausePreview() {
    previewControl.pause()
}

@objc private func stopPreview() {
    startActivityIndicator()
    previewControl.stop() {
        self.stopActivityIndicator()
    }
}
...

class PreviewStreamControl {

    var delegate: PreviewStreamControlDelegate?
    var previewReceiver: PreviewStreamReceiver!
    var buffer: PreviewStreamBuffer = PreviewStreamBuffer()
    var videoControl: PreviewStreamVideoControl = PreviewStreamVideoControl()
    var audioControl: PreviewStreamAudioControl = PreviewStreamAudioControl()

    private let ptsDivider: UInt32 = 90
    private var currentPreviewMediaItem: MediaItem? = nil

    init() {
        previewReceiver = PreviewStreamReceiver(stateDelegate: self, bufferDelegate: buffer)
        buffer.delegate = self
        videoControl.sendNewVideoFrameBlock = {
            self.sendNewVideoFrame()
        }
    }

    deinit {
        previewReceiver.stop()
    }

    func startPreviewFor(mediaItem: MediaItem, _ completion: (() -> Void)? = nil) {
        previewReceiver.start()

        stop {
            self.setupForMediaItem(mediaItem)
            self.currentPreviewMediaItem = mediaItem
            self.sendStartPreviewFor(mediaItem, completion)
        }
    }

    func pause() {
        videoControl.pause()
        audioControl.pause()
        if let delegate = delegate {
            delegate.previewDidPause(videoControl.paused)
        }
    }

    func stop(completion: (() -> Void)? = nil) {
        videoControl.stop()
        audioControl.stop()
        buffer.writeEnabled = false
        buffer.clear()
        if let delegate = delegate {
            delegate.previewDidStop()
        }

        if previewReceiver.receiving {
            if let currentPreviewMediaItem = currentPreviewMediaItem {
                sendStopPreviewFor(currentPreviewMediaItem, completion)
            }
        }
        else {
            if let completion = completion {
                completion()
            }
        }
    }
...
```

### Backchannel notifications

Backchannel is used to receive notifications about changes on the camera. For example, if a user presses the Record button on the camera you receive a *recording_started* notification. System alerts are also sent through the backchannel. For example, if the memory or SD card is full you receive a *memory_low* notification. Backchannel communication is performed over TCP protocol. Together with a notification identifier some additional information can be sent from the camera. For a detailed list of notifications take a look at [Backchannel notification](http://developer.tomtom.com/products/sports/cameramediaserver/backchannelnotifications) section of the [Camera Media Server API](http://developer.tomtom.com/products/sports/cameramediaserver) document.
To receive notifications you need to implement the *BackchannelNotificationDelegate* protocol and create a TCP connection using *BackchannelNotificationStream*. The connection port is defined by the camera and it is defined as part of the *CameraStatus* model.

```swift
class BackchannelReceiver: BackchannelNotificationDelegate {

    var backchannelNotificationStream: BackchannelNotificationStream!

    init() {
        backchannelNotificationStream = BackchannelNotificationStream(delegate: self)
    }

    func start() {
        restClient.getStatus { (cameraStatus) in
            let backchannelPort = cameraStatus.backchannelPort
            backchannelNotificationStream.startOnHost(restClient.IPAddress, port: UInt16(backchannelPort))
        }
    }

    func notificationReceived(notificationId: String, withParameters: AnyObject?) {
        // notification received
    }

    func backChannelDidDisconnect() {
        // TCP disconnected
    }
}
```

### Limitations

While you are free to use all communication channels with the TomTom Bandit Action Camera there are some limitations that you should be aware of as follows:
- Only one viewfinder stream can be started. Trying to start a viewfinder stream while one is already active will result in an error.
- You can preview only one video at any given time.
- There is a limit of 5 concurrent connections to the camera. If you are, for example, downloading thumbnails for all videos make sure you do it in batches or sequentially. Starting too many REST calls at the same time will result in an error.


## Licence

Licensed under the Apache Licence, Version 2.0 (the "Licence");
you may not use this file except in compliance with the Licence.
You may obtain a copy of the Licence at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the Licence is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the Licence for the specific language governing permissions and
limitations under the Licence.


## Copyright (C) 2015-2016, TomTom International BV. All rights reserved.
----

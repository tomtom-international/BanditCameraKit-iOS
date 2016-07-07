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

import CocoaAsyncSocket

/**
 *  @brief Preview stream header type
 */
public struct PreviewStreamHeaderType {
    public static let Video: UInt32 = 0
    public static let Audio: UInt32 = 1
    public static let StartOfStream: UInt32 = 127
    public static let EndOfStream: UInt32 = 128
}

/**
 *  @brief Preview stream header properties
 */
public struct PreviewStreamHeader {
    public var version: UInt32 = 0
    public var type: UInt32 = UInt32.max
    public var sizeOfFrameInBytes: UInt32 = 0
    public var presentationTimestamp: UInt32 = 0
    public var status: UInt32 = 0
    
    public init() {
    }
}

/**
 *  @brief Preview stream header properties byte ranges
 */
private struct PreviewStreamHeaderDefinition {
    static let VersionRange: NSRange = NSRange(location: 0, length: 4)
    static let HeaderTypeRange: NSRange = NSRange(location: 4, length: 4)
    static let SizeOfFrameInBytesRange: NSRange = NSRange(location: 8, length: 4)
    static let PresentationTimestampRange: NSRange = NSRange(location: 12, length: 4)
    static let StatusRange: NSRange = NSRange(location: 16, length: 4)
}

/**
 *  @brief CocoaAsyncSocket read tags
 */
private struct PreviewStreamReceiverReadDataTags {
    static let Header = 0
    static let Frame = 1
}

/// Preview stream receiver object used by the camera to send preview frames
public class PreviewStreamReceiver {
    
    public static let previewHeaderSizeInBytes: Int = sizeof(PreviewStreamHeader)
    public static let minimumListeningPort: UInt16 = 4010
    public static let maximumListeningPort: UInt16 = 4099

    public private(set) var listening: Bool = false
    public private(set) var receiving: Bool = false
    public private(set) var listeningPort: UInt16 = PreviewStreamReceiver.minimumListeningPort
    public var readDataTimeout: NSTimeInterval

    private let defaultReadDataTimeout: NSTimeInterval = 60
    private let tryToReadMoreDataInterval: NSTimeInterval = 0.3
    private var listeningSocket: GCDAsyncSocket = GCDAsyncSocket()
    private var receivingSocket: GCDAsyncSocket? = nil
    private var lastReceivedHeader: PreviewStreamHeader = PreviewStreamHeader()
    private unowned var stateDelegate: PreviewStreamReceiverStateDelegate
    private unowned var bufferDelegate: PreviewStreamReceiverBufferDelegate
    
    /**
     Creates the preview stream receiver object
     
     - parameter stateDelegate:  State delegate object
     - parameter bufferDelegate: Buffer delegate object
     */
    public init(stateDelegate: PreviewStreamReceiverStateDelegate, bufferDelegate: PreviewStreamReceiverBufferDelegate) {
        self.stateDelegate = stateDelegate
        self.bufferDelegate = bufferDelegate
        listeningSocket.delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        readDataTimeout = defaultReadDataTimeout
    }
    
    deinit {
        stop()
    }
    
    /**
     Start listening
     */
    public func start() {
        if listening == false {
            listeningSocket.delegate = self
            tryToOpenListeningSocket()
        }
    }

    /**
     Stop receiving and listening
     */
    public func stop() {
        stopReceiving()
        listeningSocket.delegate = nil
        listeningSocket.disconnect()
        listening = false
    }
    
    /**
     Stop receiving preview stream
     */
    public func stopReceiving() {
        stateDelegate.previewDidDisconnect()
        if let receivingSocket = receivingSocket {
            receivingSocket.delegate = nil
            receivingSocket.disconnect()
        }
        receivingSocket = nil
        receiving = false
    }

    /**
     Try to open listening socket on one of the listening ports in the defined range
     */
    private func tryToOpenListeningSocket() {
        do {
            try listeningSocket.acceptOnPort(listeningPort)
            listening = true
        }
        catch {
            if listeningPort < PreviewStreamReceiver.maximumListeningPort {
                log.verbose("Failed to start preview receiver on port \(listeningPort)")
                listeningPort += 1
                tryToOpenListeningSocket()
            }
            else {
                log.error("Failed to start preview receiver on any port")
            }
        }
    }
    
    /**
     Parses the received preview header
     
     - parameter data: Header data
     */
    private func parseHeaderData(data: NSData) {
        data.getBytesSwapInt32BigToHost(&lastReceivedHeader.version, range: PreviewStreamHeaderDefinition.VersionRange)
        data.getBytesSwapInt32BigToHost(&lastReceivedHeader.type, range: PreviewStreamHeaderDefinition.HeaderTypeRange)
        data.getBytesSwapInt32BigToHost(&lastReceivedHeader.sizeOfFrameInBytes, range: PreviewStreamHeaderDefinition.SizeOfFrameInBytesRange)
        data.getBytesSwapInt32BigToHost(&lastReceivedHeader.presentationTimestamp, range: PreviewStreamHeaderDefinition.PresentationTimestampRange)
        data.getBytesSwapInt32BigToHost(&lastReceivedHeader.status, range: PreviewStreamHeaderDefinition.StatusRange)

        if lastReceivedHeader.type == PreviewStreamHeaderType.StartOfStream {
            stateDelegate.previewStartOfStreamReceived()
            readNextHeader()
        }
        else if lastReceivedHeader.type == PreviewStreamHeaderType.EndOfStream {
            stateDelegate.previewEndOfStreamReceived()
            stopReceiving()
        }
        else if lastReceivedHeader.type == PreviewStreamHeaderType.Video || lastReceivedHeader.type == PreviewStreamHeaderType.Audio {
            readNextFrame()
        }
        else {
            log.error("Received wrong header data")
            stopReceiving()
        }
    }

    /**
     Parses the received preview video/audio frame
     
     - parameter data: Frame data
     */
    private func parseFrameData(data: NSData) {
        if lastReceivedHeader.type == PreviewStreamHeaderType.Video {
            bufferDelegate.previewVideoFrameReceived(data, forPresentationTimeStamp: lastReceivedHeader.presentationTimestamp)
        }
        else if lastReceivedHeader.type == PreviewStreamHeaderType.Audio {
            bufferDelegate.previewAudioFrameReceived(data, forPresentationTimeStamp: lastReceivedHeader.presentationTimestamp)
        }
        tryToReadMoreData()
    }
    
    /**
     Reads next header
     */
    private func readNextHeader() {
        receivingSocket?.readDataToLength(UInt(PreviewStreamReceiver.previewHeaderSizeInBytes), withTimeout: readDataTimeout, tag: PreviewStreamReceiverReadDataTags.Header)
    }

    /**
     Reads next frame
     */
    private func readNextFrame() {
        receivingSocket?.readDataToLength(UInt(lastReceivedHeader.sizeOfFrameInBytes), withTimeout: readDataTimeout, tag: PreviewStreamReceiverReadDataTags.Frame)
    }

    /**
     Check with the buffer if reading can continue or needs to be put briefly on hold
     */
    private func tryToReadMoreData() {
        if receiving == false {
            return
        }
        
        if bufferDelegate.previewSafeToReadMoreData() {
            readNextHeader()
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(tryToReadMoreDataInterval * Double(NSEC_PER_SEC))), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                self.tryToReadMoreData()
            }
        }
    }
}

extension PreviewStreamReceiver: GCDAsyncSocketDelegate {
    @objc public func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        if sock === receivingSocket {
            if tag == PreviewStreamReceiverReadDataTags.Header {
                parseHeaderData(data)
            }
            else if tag == PreviewStreamReceiverReadDataTags.Frame {
                parseFrameData(data)
            }
        }
    }
    
    @objc public func socket(sock: GCDAsyncSocket!, shouldTimeoutReadWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        if sock === receivingSocket {
            stopReceiving()
        }
        return 0
    }
    
    @objc public func socket(sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
        receivingSocket = newSocket
        receiving = true
        receivingSocket?.readDataToLength(UInt(PreviewStreamReceiver.previewHeaderSizeInBytes), withTimeout: readDataTimeout, tag: PreviewStreamReceiverReadDataTags.Header)
        stateDelegate.previewDidConnect()
    }
    
    @objc public func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        if sock === receivingSocket {
            stopReceiving()

            if let error = err {
                log.warning("Receiving socket disconnected with error: \(error.localizedDescription)")
            }
        }
    }
}

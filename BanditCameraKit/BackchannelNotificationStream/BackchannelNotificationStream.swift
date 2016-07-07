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

import Foundation
import CocoaAsyncSocket

/**
 *  @brief <#Description#>
 */
public struct BackchannelNotification {
    public static let ViewfinderStartedNotification = "viewfinder_started"
    public static let ViewfinderStoppedNotification = "viewfinder_stopped"
    public static let RecordingStartedNotification = "recording_started"
    public static let RecordingStoppedNotification = "recording_stopped"
    public static let HighlightCreatedNotification = "tag_created"
    public static let WifiStoppedNotification = "wifi_stopped"
    public static let MemoryLowNotification = "memory_low"
    public static let MemoryErrorNotification = "memory_error"
    public static let ImageCapturedNotification = "photo_captured"
    public static let TranscodingProgressNotification = "transcoding_progress"
    public static let ShuttingDownNotification = "shutting_down"
}

/// <#Description#>
public class BackchannelNotificationStream {
 
    private static let NotificationStreamConnectTimeout = 1
    private static let NotificationStreamReadTimeout = -1
    private var clientSocket: GCDAsyncSocket?
    private let socketReadSeparator = NSData(bytes:"\n", length:1)

    private unowned var delegate: BackchannelNotificationDelegate

    /**
     <#Description#>
     
     - parameter delegate: <#delegate description#>
     
     - returns: <#return value description#>
     */
    public init(delegate: BackchannelNotificationDelegate) {
        self.delegate = delegate
    }
    
    /**
     <#Description#>
     
     - parameter hostName: <#hostName description#>
     - parameter port:     <#port description#>
     */
    public func startOnHost(hostName: String, port: UInt16) {
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try clientSocket?.connectToHost(hostName, onPort:port)
        }
        catch let error as NSError {
            log.error("Failed to connect to \(hostName) and port \(port), with error: \(error.localizedDescription)")
        }
    }
    
    /**
     <#Description#>
     */
    public func stop() {
        clientSocket?.disconnect()
        clientSocket = nil
    }
    
    /**
     <#Description#>
     
     - parameter notificationId: <#notificationId description#>
     - parameter parameters:     <#parameters description#>
     */
    public func notificationReceived(notificationId: String, withParameters parameters: AnyObject?) {
        delegate.notificationReceived(notificationId, withParameters:parameters)
    }

    /**
     <#Description#>
     */
    public func backChannelDidDisconnect() {
        delegate.backChannelDidDisconnect()
    }

    /**
     <#Description#>
     */
    private func waitForNextNotification() {
        clientSocket?.readDataToData(socketReadSeparator, withTimeout:NSTimeInterval(BackchannelNotificationStream.NotificationStreamReadTimeout), tag: 0)
    }
}

// MARK: - GCDAsyncSocketDelegate

extension BackchannelNotificationStream : GCDAsyncSocketDelegate {
    /**
     <#Description#>
     
     - parameter sock: <#sock description#>
     */
    @objc public func socketDidCloseReadStream(sock: GCDAsyncSocket!) {
        backChannelDidDisconnect()
        stop()
    }
    
    /**
     <#Description#>
     
     - parameter sock: <#sock description#>
     - parameter err:  <#err description#>
     */
    @objc public func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        backChannelDidDisconnect()
    }
    
    /**
     <#Description#>
     
     - parameter sock: <#sock description#>
     - parameter host: <#host description#>
     - parameter port: <#port description#>
     */
    @objc public func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        waitForNextNotification()
    }
    
    /**
     <#Description#>
     
     - parameter sock: <#sock description#>
     - parameter data: <#data description#>
     - parameter tag:  <#tag description#>
     */
    @objc public func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        guard let notifications = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject],
            notificationIds = notifications?.keys else {
                log.warning("Could not parse JSON notification data")
                return
        }
            
        for notification in notificationIds {
            notificationReceived(notification, withParameters: notifications![notification])
        }
        
        waitForNextNotification()
    }
}

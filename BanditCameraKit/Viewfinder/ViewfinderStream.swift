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
public struct ViewfinderMessageType {
    public static let ViewfinderMessageFrameStart: UInt8 = 0
    public static let ViewfinderMessageFrameData: UInt8 = 1
}

/**
 *  @brief <#Description#>
 */
public struct ViewfinderMessageProperties {
    public static let ViewfinderPacketSync: UInt16 = 0x55AA
    public static let ViewfinderHeaderSizeInBytes: Int = 7
    public static let ViewfinderPacketSizeInBytes: Int = 1024
}

/**
 *  @brief <#Description#>
 */
private struct ViewfinderHeaderDefinition {
    static let PacketSyncRange: NSRange = NSRange(location:0, length:sizeof(UInt16))
    static let MessageTypeRange: NSRange = NSRange(location:2, length:sizeof(UInt8))
    static let PacketNumberRange: NSRange = NSRange(location:3, length:sizeof(UInt16))
    static let PayloadLengthRange: NSRange = NSRange(location:5, length:sizeof(UInt16))
    static let RequiredPayloadLengthRange: NSRange = NSRange(location:7, length:sizeof(UInt32))
    static let PresentationTimestampRange: NSRange = NSRange(location:11, length:sizeof(UInt32))
}

/**
 *  @brief <#Description#>
 */
public struct ViewfinderHeader {
    public var packetSync: UInt16 = 0
    public var messageType: UInt8 = UInt8.max
    public var packetNumber: UInt16 = 0
    public var payloadLength: UInt16 = 0
    
    public init() {
    }
}

/// <#Description#>
public class ViewfinderStream {
    
    private var clientSocket: GCDAsyncUdpSocket?
    private var packetCount: UInt16 = 0
    private var frameData: NSMutableData = NSMutableData()
    private var payloadLengthRequired: UInt32 = 0
    private var waitingForStartFrame: Bool = true
    
    private unowned var delegate: ViewfinderStreamDelegate
    
    /**
     <#Description#>
     
     - parameter delegate: <#delegate description#>
     
     - returns: <#return value description#>
     */
    public init(delegate: ViewfinderStreamDelegate) {
        self.delegate = delegate
    }
    
    /**
     <#Description#>
     
     - parameter port: <#port description#>
     */
    public func start(onPort port: UInt16) {
        clientSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try clientSocket?.bindToPort(port)
            try clientSocket?.beginReceiving()
        }
        catch let error as NSError {
            log.error("Failed to start viewfinder client on port \(port), with error: \(error.localizedDescription)")
        }
        
        waitingForStartFrame = true
    }
    
    /**
     <#Description#>
     */
    public func stop() {
        clientSocket?.close()
        clientSocket = nil
    }
    
    /**
     <#Description#>
     
     - parameter presentationTimestamp: <#presentationTimestamp description#>
     */
    public func presentationTimestampReceived(presentationTimestamp: Double) {
        delegate.presentationTimestampReceived(presentationTimestamp)
    }
    
    /**
     <#Description#>
     
     - parameter frame: <#frame description#>
     */
    public func frameReceived(frame: NSData) {
        delegate.frameReceived(frame)
    }
    
    /**
     <#Description#>
     
     - parameter data: <#data description#>
     */
    func onDataReceived(data:NSData) {
        if data.length < ViewfinderMessageProperties.ViewfinderHeaderSizeInBytes {
            log.warning("Received viewfinder header of invalid length. Got data of lenght \(data.length), expected at least \(ViewfinderMessageProperties.ViewfinderHeaderSizeInBytes)")
            return
        }
        
        var messageHeader: ViewfinderHeader = ViewfinderHeader()
        
        data.getBytesSwapInt16BigToHost(&messageHeader.packetSync, range:ViewfinderHeaderDefinition.PacketSyncRange)
        
        if messageHeader.packetSync != ViewfinderMessageProperties.ViewfinderPacketSync {
            log.warning("Received incorrect Sync bytes")
            return
        }
        
        data.getBytes(&messageHeader.messageType, range:ViewfinderHeaderDefinition.MessageTypeRange)
        data.getBytesSwapInt16BigToHost(&messageHeader.packetNumber, range:ViewfinderHeaderDefinition.PacketNumberRange)
        data.getBytesSwapInt16BigToHost(&messageHeader.payloadLength, range:ViewfinderHeaderDefinition.PayloadLengthRange)
        
        if data.length != ViewfinderMessageProperties.ViewfinderHeaderSizeInBytes + Int(messageHeader.payloadLength) {
            log.warning("Received viewfinder packet of invalid length. Got data of length \(data.length), expected \(ViewfinderMessageProperties.ViewfinderHeaderSizeInBytes + Int(messageHeader.payloadLength))")
            return;
        }
        
        if messageHeader.messageType == ViewfinderMessageType.ViewfinderMessageFrameStart {
            var presentationTimeStamp: UInt32 = 0
            data.getBytesSwapInt32BigToHost(&presentationTimeStamp, range:ViewfinderHeaderDefinition.PresentationTimestampRange)
            presentationTimestampReceived(Double(unsafeBitCast(presentationTimeStamp, Float32.self)))
            data.getBytesSwapInt32BigToHost(&payloadLengthRequired, range:ViewfinderHeaderDefinition.RequiredPayloadLengthRange)
            frameData.length = 0
            packetCount = messageHeader.packetNumber + 1
            waitingForStartFrame = false
        }
        else if messageHeader.messageType == ViewfinderMessageType.ViewfinderMessageFrameData {
            if !waitingForStartFrame {
                if packetCount != messageHeader.packetNumber {
                    log.warning("Expected packet \(packetCount) but got \(messageHeader.packetNumber)")
                    waitingForStartFrame = true
                }
                else {
                    frameData.appendData(data.subdataWithRange(NSRange(location:Int(ViewfinderMessageProperties.ViewfinderHeaderSizeInBytes), length:Int(messageHeader.payloadLength))))
                    if frameData.length >= Int(payloadLengthRequired) {
                        frameReceived(frameData)
                        waitingForStartFrame = true
                    }
                    else {
                        if packetCount == UInt16.max {
                            packetCount = 0
                        }
                        else {
                            packetCount += 1
                        }
                    }
                }
            }
        }
        else {
            log.warning("Unexpected message \(messageHeader.messageType) received")
        }
    }
}

// MARK: - GCDAsyncUdpSocketDelegate

extension ViewfinderStream : GCDAsyncUdpSocketDelegate {
    /**
     <#Description#>
     
     - parameter sock:          <#sock description#>
     - parameter data:          <#data description#>
     - parameter address:       <#address description#>
     - parameter filterContext: <#filterContext description#>
     */
    @objc public func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        onDataReceived(data)
    }
}
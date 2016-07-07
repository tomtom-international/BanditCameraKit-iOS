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

/**
 *  Set of keys for serializing and deserializing CameraStatus
 */
public struct CameraStatusItemKeys {
    public static let RecordingActiveKey = "recording_active"
    public static let RecordingSecondsKey = "recording_secs"
    public static let BateryLevelPercentageKey = "battery_level_pct"
    public static let BatteryChargingKey = "battery_charging"
    public static let GnssFixKey = "gnss_fix"
    public static let GnssStrengthPercentageKey = "gnss_strength_pct"
    public static let HeartRateConnectedKey = "heart_rate_sensor_connected"
    public static let CadenceConnectedKey = "cadence_sensor_connected"
    public static let PreviewActiveKey = "preview_active"
    public static let ViewfinderActiveKey = "viewfinder_active"
    public static let ViewfinderStreamingPortKey = "viewfinder_streaming_port"
    public static let BackchannelPortKey = "backchannel_port"
    public static let MemoryFreeBytesKey = "memory_free_bytes"
    public static let RemainingTimeSecsKey = "remaining_time_secs"
    public static let RemainingPhotosKey = "remaining_photos"
    public static let TranscodingActiveKey = "transcoding_active"
    public static let TranscodingProgressKey = "transcoding_progress"
}

/// <#Description#>
public class CameraStatus : SerializableItem {

    public var recordingActive: Bool = false
    public var recordingSeconds: UInt = 0
    public var batteryLevelPercentage: UInt = 0
    public var chargingBattery: Bool = false
    public var gnssFixObtained: Bool = false
    public var previewActive: Bool = false
    public var viewfinderActive: Bool = false
    public var viewfinderStreamingPort: UInt = 0
    public var backchannelPort: UInt = 0
    public var memoryFreeBytes: UInt = 0
    public var remainingTimeSeconds: UInt = 0
    public var remainingPhotos: UInt = 0
    public var transcodingActive: Bool = false
    public var transcodingProgress: UInt = 0
    public var gnssStrengthPercentage: UInt = 0
    public var heartRateSensorConnected: Bool = false
    public var cadenceSensorConnected: Bool = false
    
    public init() {}

    /**
     Creates dictionary presentation of CameraStatus
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        return [CameraStatusItemKeys.RecordingActiveKey : self.recordingActive,
            CameraStatusItemKeys.RecordingSecondsKey : self.recordingSeconds,
            CameraStatusItemKeys.BateryLevelPercentageKey : self.batteryLevelPercentage,
            CameraStatusItemKeys.BatteryChargingKey : self.chargingBattery,
            CameraStatusItemKeys.GnssFixKey : self.gnssFixObtained,
            CameraStatusItemKeys.GnssStrengthPercentageKey : self.gnssStrengthPercentage,
            CameraStatusItemKeys.HeartRateConnectedKey : self.heartRateSensorConnected,
            CameraStatusItemKeys.CadenceConnectedKey : self.cadenceSensorConnected,
            CameraStatusItemKeys.PreviewActiveKey : self.previewActive,
            CameraStatusItemKeys.ViewfinderActiveKey : self.viewfinderActive,
            CameraStatusItemKeys.ViewfinderStreamingPortKey : self.viewfinderStreamingPort,
            CameraStatusItemKeys.BackchannelPortKey : self.backchannelPort,
            CameraStatusItemKeys.MemoryFreeBytesKey : self.memoryFreeBytes,
            CameraStatusItemKeys.RemainingTimeSecsKey : self.remainingTimeSeconds,
            CameraStatusItemKeys.RemainingPhotosKey : self.remainingPhotos,
            CameraStatusItemKeys.TranscodingActiveKey : self.transcodingActive,
            CameraStatusItemKeys.TranscodingProgressKey : self.transcodingProgress]
    }
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")
        
        guard let recordingActive = serializedItem[CameraStatusItemKeys.RecordingActiveKey] as? Bool else {
            log.error("\(CameraStatusItemKeys.RecordingActiveKey) missing in dictionary")
            return false
        }
        
        guard let recordingSeconds = serializedItem[CameraStatusItemKeys.RecordingSecondsKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.RecordingSecondsKey) missing in dictionary")
            return false
        }
        
        guard let batteryLevelPercentage = serializedItem[CameraStatusItemKeys.BateryLevelPercentageKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.BateryLevelPercentageKey) missing in dictionary")
            return false
        }
        
        guard let chargingBattery = serializedItem[CameraStatusItemKeys.BatteryChargingKey] as? Bool else {
            log.error("\(CameraStatusItemKeys.BatteryChargingKey) missing in dictionary")
            return false
        }
        
        guard let gnssFixObtained = serializedItem[CameraStatusItemKeys.GnssFixKey] as? Bool else {
            log.error("\(CameraStatusItemKeys.GnssFixKey) missing in dictionary")
            return false
        }
        
        guard let gnssStrengthPercentage = serializedItem[CameraStatusItemKeys.GnssStrengthPercentageKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.GnssStrengthPercentageKey) missing in dictionary")
            return false
        }
        
        guard let heartRateSensorConnected = serializedItem[CameraStatusItemKeys.HeartRateConnectedKey] as? Bool else {
            log.error("\(CameraStatusItemKeys.HeartRateConnectedKey) missing in dictionary")
            return false
        }
        
        guard let cadenceSensorConnected = serializedItem[CameraStatusItemKeys.CadenceConnectedKey] as? Bool else {
            log.error("\(CameraStatusItemKeys.CadenceConnectedKey) missing in dictionary")
            return false
        }
        
        guard let previewActive = serializedItem[CameraStatusItemKeys.PreviewActiveKey] as? Bool else {
            log.error("\(CameraStatusItemKeys.PreviewActiveKey) missing in dictionary")
            return false
        }
        
        guard let viewfinderActive = serializedItem[CameraStatusItemKeys.ViewfinderActiveKey] as? Bool else {
            log.error("\(CameraStatusItemKeys.ViewfinderActiveKey) missing in dictionary")
            return false
        }
        
        guard let viewfinderStreamingPort = serializedItem[CameraStatusItemKeys.ViewfinderStreamingPortKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.ViewfinderStreamingPortKey) missing in dictionary")
            return false
        }
        
        guard let backchannelPort = serializedItem[CameraStatusItemKeys.BackchannelPortKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.BackchannelPortKey) missing in dictionary")
            return false
        }

        guard let memoryFreeBytes = serializedItem[CameraStatusItemKeys.MemoryFreeBytesKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.MemoryFreeBytesKey) missing in dictionary")
            return false
        }
        
        guard let remainingTimeSeconds = serializedItem[CameraStatusItemKeys.RemainingTimeSecsKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.RemainingTimeSecsKey) missing in dictionary")
            return false
        }
        
        guard let remainingPhotos = serializedItem[CameraStatusItemKeys.RemainingPhotosKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.RemainingPhotosKey) missing in dictionary")
            return false
        }

        guard let transcodingActive = serializedItem[CameraStatusItemKeys.TranscodingActiveKey] as? Bool else {
            log.error("\(CameraStatusItemKeys.TranscodingActiveKey) missing in dictionary")
            return false
        }

        guard let transcodingProgress = serializedItem[CameraStatusItemKeys.TranscodingProgressKey] as? UInt else {
            log.error("\(CameraStatusItemKeys.TranscodingProgressKey) missing in dictionary")
            return false
        }
        
        self.recordingActive = recordingActive
        self.recordingSeconds = recordingSeconds
        self.batteryLevelPercentage = batteryLevelPercentage
        self.chargingBattery = chargingBattery
        self.gnssFixObtained = gnssFixObtained
        self.previewActive = previewActive
        self.viewfinderActive = viewfinderActive
        self.transcodingActive = transcodingActive
        self.heartRateSensorConnected = heartRateSensorConnected
        self.cadenceSensorConnected = cadenceSensorConnected
        self.viewfinderStreamingPort = viewfinderStreamingPort
        self.backchannelPort = backchannelPort
        self.memoryFreeBytes = memoryFreeBytes
        self.remainingTimeSeconds = remainingTimeSeconds
        self.remainingPhotos = remainingPhotos
        self.transcodingProgress = transcodingProgress
        self.gnssStrengthPercentage = gnssStrengthPercentage

        return true
    }
}

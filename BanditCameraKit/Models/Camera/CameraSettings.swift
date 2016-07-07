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
 *  Set of keys for serializing and deserializing CameraSettings
 */
public struct CameraSettingsItemKeys {
    public struct DeviceSection {
        public static let Key = "camera"
        public static let SerialNumberKey = "serial_number"
        public static let BLECameraIDNumberKey = "ble_camera_id"
        public static let BLEVerificationCodeKey = "ble_verification_code"
        public static let GNSSEnabledKey = "gnss_enabled"
        public static let SoundEnabledKey = "sound_enabled"
        public static let LightsEnabledKey = "lights_enabled"
        public static let ImageRotationEnabledKey = "image_rotation_enabled"
        public static let ExternalMicrophoneEnabledKey = "external_microphone_enabled"
        public static let MeteringKey = "metering"
        public static let WhiteBalanceKey = "white_balance_mode"
        public static let VideoStabilisationEnabledKey = "video_stabilisation_enabled"
    }
    public struct WiFiSection {
        public static let Key = "wifi"
        public static let SSIDKey = "ssid"
    }
    public static let SceneSectionKey = "scene"
    public static let VideoSectionKey = "video"
    public static let ImageSectionKey = "image"
}

/**
 <#Description#>
 
 - Center: <#Center description#>
 - :       <# description#>
 */
public enum CameraMetering: String {
    case Center = "center",
    Normal = "normal",
    Wide = "wide"
}

/**
 <#Description#>
 
 - Auto: <#Auto description#>
 - :     <# description#>
 */
public enum CameraWhiteBalanceMode: String {
    case Auto = "auto",
    Cloudy = "7500K",
    Daylight = "5000K",
    Fluorescent = "4000K",
    Tungsten = "3000K",
    Candlelight = "2000K"
}

/// <#Description#>
public class CameraSettings: SerializableItem {

    public var serialNumber: String = ""
    public var bleCameraId: String = ""
    public var bleVerificationCode: String = ""
    public var gnssEnabled: Bool = false
    public var soundEnabled: Bool = false
    public var lightsEnabled: Bool = false
    public var imageRotationEnabled: Bool = false
    public var externalMicrophoneEnabled: Bool = false
    public var metering: CameraMetering = .Center
    public var whiteBalanceMode: CameraWhiteBalanceMode = .Auto
    public var videoStabilisationEnabled: Bool = false
    public var wifiSSID: String = ""
    public var sceneMode: SceneMode!
    public var recordingMode: RecordingMode!
    
    public init() {}

    /**
     Creates dictionary presentation of CameraSettings
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        let wifiSectionDictionary = [CameraSettingsItemKeys.WiFiSection.SSIDKey: wifiSSID]

        var recordingSectionKey = CameraSettingsItemKeys.VideoSectionKey
        if recordingMode.type == .Image {
            recordingSectionKey = CameraSettingsItemKeys.ImageSectionKey
        }
        
        return [CameraSettingsItemKeys.DeviceSection.Key: deviceSettingsDictionary(),
                CameraSettingsItemKeys.WiFiSection.Key: wifiSectionDictionary,
                CameraSettingsItemKeys.SceneSectionKey: sceneMode.toDictionary(),
                recordingSectionKey: recordingMode.toDictionary()]
    }
    
    /**
     <#Description#>
     
     - returns: <#return value description#>
     */
    public func deviceSettingsDictionary() -> [String: AnyObject] {
        return [CameraSettingsItemKeys.DeviceSection.SerialNumberKey: serialNumber,
                CameraSettingsItemKeys.DeviceSection.BLECameraIDNumberKey: bleCameraId,
                CameraSettingsItemKeys.DeviceSection.BLEVerificationCodeKey: bleVerificationCode,
                CameraSettingsItemKeys.DeviceSection.GNSSEnabledKey: gnssEnabled,
                CameraSettingsItemKeys.DeviceSection.SoundEnabledKey: soundEnabled,
                CameraSettingsItemKeys.DeviceSection.LightsEnabledKey: lightsEnabled,
                CameraSettingsItemKeys.DeviceSection.ImageRotationEnabledKey: imageRotationEnabled,
                CameraSettingsItemKeys.DeviceSection.ExternalMicrophoneEnabledKey: externalMicrophoneEnabled,
                CameraSettingsItemKeys.DeviceSection.MeteringKey: metering.rawValue,
                CameraSettingsItemKeys.DeviceSection.WhiteBalanceKey: whiteBalanceMode.rawValue,
                CameraSettingsItemKeys.DeviceSection.VideoStabilisationEnabledKey: videoStabilisationEnabled]
    }
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")

        // Device settings
        guard let deviceSettings = serializedItem[CameraSettingsItemKeys.DeviceSection.Key] as? [String: AnyObject] else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.Key) missing in dictionary")
            return false
        }
        
        guard let serialNumber = deviceSettings[CameraSettingsItemKeys.DeviceSection.SerialNumberKey] as? String else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.SerialNumberKey) missing in dictionary")
            return false
        }

        guard let bleCameraId = deviceSettings[CameraSettingsItemKeys.DeviceSection.BLECameraIDNumberKey] as? String else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.BLECameraIDNumberKey) missing in dictionary")
            return false
        }

        guard let bleVerificationCode = deviceSettings[CameraSettingsItemKeys.DeviceSection.BLEVerificationCodeKey] as? String else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.BLEVerificationCodeKey) missing in dictionary")
            return false
        }

        guard let gnssEnabled = deviceSettings[CameraSettingsItemKeys.DeviceSection.GNSSEnabledKey] as? Bool else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.GNSSEnabledKey) missing in dictionary")
            return false
        }

        guard let soundEnabled = deviceSettings[CameraSettingsItemKeys.DeviceSection.SoundEnabledKey] as? Bool else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.SoundEnabledKey) missing in dictionary")
            return false
        }

        guard let lightsEnabled = deviceSettings[CameraSettingsItemKeys.DeviceSection.LightsEnabledKey] as? Bool else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.LightsEnabledKey) missing in dictionary")
            return false
        }

        guard let imageRotationEnabled = deviceSettings[CameraSettingsItemKeys.DeviceSection.ImageRotationEnabledKey] as? Bool else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.ImageRotationEnabledKey) missing in dictionary")
            return false
        }

        guard let externalMicrophoneEnabled = deviceSettings[CameraSettingsItemKeys.DeviceSection.ExternalMicrophoneEnabledKey] as? Bool else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.ExternalMicrophoneEnabledKey) missing in dictionary")
            return false
        }

        guard let meteringString = deviceSettings[CameraSettingsItemKeys.DeviceSection.MeteringKey] as? String else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.MeteringKey) missing in dictionary")
            return false
        }

        guard let metering = CameraMetering(rawValue: meteringString) else {
            log.error("Failed to create \(CameraSettingsItemKeys.DeviceSection.MeteringKey)")
            return false
        }

        guard let whiteBalanceModeString = deviceSettings[CameraSettingsItemKeys.DeviceSection.WhiteBalanceKey] as? String else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.WhiteBalanceKey) missing in dictionary")
            return false
        }

        guard let whiteBalanceMode = CameraWhiteBalanceMode(rawValue: whiteBalanceModeString) else {
            log.error("Failed to create \(CameraSettingsItemKeys.DeviceSection.WhiteBalanceKey)")
            return false
        }

        guard let videoStabilisationEnabled = deviceSettings[CameraSettingsItemKeys.DeviceSection.VideoStabilisationEnabledKey] as? Bool else {
            log.error("\(CameraSettingsItemKeys.DeviceSection.VideoStabilisationEnabledKey) missing in dictionary")
            return false
        }
        
        self.serialNumber = serialNumber
        self.bleCameraId = bleCameraId
        self.bleVerificationCode = bleVerificationCode
        self.gnssEnabled = gnssEnabled
        self.soundEnabled = soundEnabled
        self.lightsEnabled = lightsEnabled
        self.imageRotationEnabled = imageRotationEnabled
        self.externalMicrophoneEnabled = externalMicrophoneEnabled
        self.metering = metering
        self.whiteBalanceMode = whiteBalanceMode
        self.videoStabilisationEnabled = videoStabilisationEnabled
        
        // WiFi settings
        guard let wifiSettings = serializedItem[CameraSettingsItemKeys.WiFiSection.Key] as? [String: AnyObject] else {
            log.error("\(CameraSettingsItemKeys.WiFiSection.Key) missing in dictionary")
            return false
        }

        guard let wifiSSID = wifiSettings[CameraSettingsItemKeys.WiFiSection.SSIDKey] as? String else {
            log.error("\(CameraSettingsItemKeys.WiFiSection.SSIDKey) missing in dictionary")
            return false
        }
        
        self.wifiSSID = wifiSSID

        // Scene settings
        guard let sceneDictionary = serializedItem[CameraSettingsItemKeys.SceneSectionKey] as? [String: AnyObject] else {
            log.error("\(CameraSettingsItemKeys.SceneSectionKey) missing in dictionary")
            return false
        }

        sceneMode = SceneMode()
        guard sceneMode.fromDictionary(sceneDictionary) else {
            log.error("Failed to parse scene mode")
            return false
        }

        // Recording settings
        recordingMode = RecordingMode()

        if let videoDictionary = serializedItem[CameraSettingsItemKeys.VideoSectionKey] as? [String: AnyObject] {
            guard recordingMode.fromDictionary(videoDictionary) else {
                log.error("Failed to parse video mode")
                return false
            }
        }
        else if let imageDictionary = serializedItem[CameraSettingsItemKeys.ImageSectionKey] as? [String: AnyObject] {
            guard recordingMode.fromDictionary(imageDictionary) else {
                log.error("Failed to parse image mode")
                return false
            }
        }
        else {
            log.error("\(CameraSettingsItemKeys.VideoSectionKey) and \(CameraSettingsItemKeys.ImageSectionKey) missing in dictionary")
            return false
        }

        return true
    }
}

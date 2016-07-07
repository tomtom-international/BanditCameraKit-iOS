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

/**
 *  Set of keys for serializing and deserializing RecordingMode
 */
public struct RecordingModeItemKeys {
    public static let ModeKey = "mode"
    public static let ResolutionKey = "resolution"
    public static let FrameRateKey = "framerate_fps"
    public static let FieldOfViewKey = "fov"
    public static let SlowMotionRateKey = "slow_motion_rate"
    public static let IntervalSecondsKey = "interval_secs"
    public static let DurationSecondsKey = "duration_secs"
    public static let BurstCountKey = "burst_count"
    public static let ScenesDisabledKey = "scenes_disabled"
}

/**
 <#Description#>
 
 - Video: <#Video description#>
 - :      <# description#>
 */
public enum RecordingModeType: Int {
    case Video = 0,
    Image = 1
}

/**
 <#Description#>
 
 */
public enum RecordingModeMode: String {
    case VideoNormal = "normal",
    VideoSlowMotion = "slow_motion",
    VideoTimeLapse = "time_lapse",
    VideoNightLapse = "night_lapse",
    ImageSingle = "single",
    ImageBurst = "burst",
    ImageContinuous = "continuous",
    Unsupported = "unsupported"
}

/**
 <#Description#>
 
 - Image_16MP: <#Image_16MP description#>
 - :           <# description#>
 */
public enum RecordingModeResolution: String {
    case Image_16MP = "16MP",
    Image_8MP = "8MP",
    UHD_4K = "4k",
    WQHD_2K7 = "2.7k",
    FHD_1080p = "1080p",
    HD_720p = "720p",
    WVGA = "wvga",
    Unsupported = "unsupported"
}

/**
 <#Description#>
 
 - Normal: <#Normal description#>
 - :       <# description#>
 */
public enum RecordingModeFieldOfView: String {
    case Normal = "normal",
    Wide = "wide",
    Unsupported = "unsupported"
}

/// <#Description#>
public class RecordingMode: SerializableItem {

    public var type: RecordingModeType = .Video
    public var mode: RecordingModeMode = .VideoNormal
    public var resolution: RecordingModeResolution = .FHD_1080p
    public var frameRate: UInt? = nil
    public var fieldOfView: RecordingModeFieldOfView? = nil
    public var slowMotionRate: UInt? = nil
    public var intervalSeconds: Double? = nil
    public var durationSeconds: Double? = nil
    public var burstCountSeconds: UInt? = nil
    public var scenesDisabled: [String]? = nil
    
    public init() {}

    /**
     Creates dictionary presentation of RecordingMode
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        var recordingModeDictionary: [String: AnyObject] = [RecordingModeItemKeys.ModeKey: mode.rawValue,
                                       RecordingModeItemKeys.ResolutionKey: resolution.rawValue]
        
        if let frameRate = frameRate {
            recordingModeDictionary.updateValue(frameRate, forKey: RecordingModeItemKeys.FrameRateKey)
        }
        
        if let fieldOfView = fieldOfView {
            recordingModeDictionary.updateValue(fieldOfView.rawValue, forKey: RecordingModeItemKeys.FieldOfViewKey)
        }

        if let slowMotionRate = slowMotionRate {
            recordingModeDictionary.updateValue(slowMotionRate, forKey: RecordingModeItemKeys.SlowMotionRateKey)
        }

        if let intervalSeconds = intervalSeconds {
            recordingModeDictionary.updateValue(intervalSeconds, forKey: RecordingModeItemKeys.IntervalSecondsKey)
        }

        if let durationSeconds = durationSeconds {
            recordingModeDictionary.updateValue(durationSeconds, forKey: RecordingModeItemKeys.DurationSecondsKey)
        }

        if let burstCountSeconds = burstCountSeconds {
            recordingModeDictionary.updateValue(burstCountSeconds, forKey: RecordingModeItemKeys.BurstCountKey)
        }

        if let scenesDisabled = scenesDisabled {
            recordingModeDictionary.updateValue(scenesDisabled, forKey: RecordingModeItemKeys.ScenesDisabledKey)
        }
        
        return recordingModeDictionary
    }
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")
        
        guard let modeString = serializedItem[RecordingModeItemKeys.ModeKey] as? String else {
            log.error("\(RecordingModeItemKeys.ModeKey) missing in dictionary")
            return false
        }
        
        guard let resolutionString = serializedItem[RecordingModeItemKeys.ResolutionKey] as? String else {
            log.error("\(RecordingModeItemKeys.ResolutionKey) missing in dictionary")
            return false
        }

        if let fieldOfViewString = serializedItem[RecordingModeItemKeys.FieldOfViewKey] as? String {
            fieldOfView = RecordingModeFieldOfView(rawValue: fieldOfViewString) ?? .Unsupported
        }
        
        self.mode = RecordingModeMode(rawValue: modeString) ?? .Unsupported
        self.resolution = RecordingModeResolution(rawValue: resolutionString) ?? .Unsupported
        self.frameRate = serializedItem[RecordingModeItemKeys.FrameRateKey] as? UInt
        self.slowMotionRate = serializedItem[RecordingModeItemKeys.SlowMotionRateKey] as? UInt
        self.intervalSeconds = serializedItem[RecordingModeItemKeys.IntervalSecondsKey] as? Double
        self.durationSeconds = serializedItem[RecordingModeItemKeys.DurationSecondsKey] as? Double
        self.burstCountSeconds = serializedItem[RecordingModeItemKeys.BurstCountKey] as? UInt
        self.scenesDisabled = serializedItem[RecordingModeItemKeys.ScenesDisabledKey] as? [String]
        
        if self.resolution == .Image_8MP || self.resolution == .Image_16MP {
            self.type = .Image
        }
        
        return true
    }
}

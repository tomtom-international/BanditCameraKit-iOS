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
 *  Set of keys for serializing and deserializing SceneMode
 */
public struct SceneModeItemKeys {
    public static let ModeKey = "mode"
    public static let BrightnessKey = "brightness"
    public static let ContrastKey = "contrast"
    public static let HueKey = "hue"
    public static let SaturationKey = "saturation"
    public static let SharpnessKey = "sharpness"
}

/**
 <#Description#>
 
 */
public enum SceneModeMode: String {
    case Auto = "auto",
    Bright = "bright",
    Night = "night",
    Underwater = "underwater",
    Unsupported = "unsupported"
}

/// <#Description#>
public class SceneMode: SerializableItem {
    
    public var mode: SceneModeMode = .Auto
    public var brightness: UInt = 0
    public var contrast: UInt = 0
    public var hue: UInt = 0
    public var saturation: UInt = 0
    public var sharpness: UInt = 0
    
    public init() {}
    
    /**
     Creates dictionary presentation of SceneMode
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        return [SceneModeItemKeys.ModeKey: mode.rawValue,
                SceneModeItemKeys.BrightnessKey: brightness,
                SceneModeItemKeys.ContrastKey: contrast,
                SceneModeItemKeys.HueKey: hue,
                SceneModeItemKeys.SaturationKey: saturation,
                SceneModeItemKeys.SharpnessKey: sharpness]
    }
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")
        
        guard let modeString = serializedItem[SceneModeItemKeys.ModeKey] as? String else {
            log.error("\(SceneModeItemKeys.ModeKey) missing in dictionary")
            return false
        }

        guard let brightness = serializedItem[SceneModeItemKeys.BrightnessKey] as? UInt else {
            log.error("\(SceneModeItemKeys.BrightnessKey) missing in dictionary")
            return false
        }
        
        guard let contrast = serializedItem[SceneModeItemKeys.ContrastKey] as? UInt else {
            log.error("\(SceneModeItemKeys.ContrastKey) missing in dictionary")
            return false
        }
        
        guard let hue = serializedItem[SceneModeItemKeys.HueKey] as? UInt else {
            log.error("\(SceneModeItemKeys.HueKey) missing in dictionary")
            return false
        }
        
        guard let saturation = serializedItem[SceneModeItemKeys.SaturationKey] as? UInt else {
            log.error("\(SceneModeItemKeys.SaturationKey) missing in dictionary")
            return false
        }
        
        guard let sharpness = serializedItem[SceneModeItemKeys.SharpnessKey] as? UInt else {
            log.error("\(SceneModeItemKeys.SharpnessKey) missing in dictionary")
            return false
        }
        
        self.mode = SceneModeMode(rawValue: modeString) ?? .Unsupported
        self.brightness = brightness
        self.contrast = contrast
        self.hue = hue
        self.saturation = saturation
        self.sharpness = sharpness
        
        return true
    }
}

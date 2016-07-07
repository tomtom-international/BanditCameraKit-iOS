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
 *  Set of keys for serializing and deserializing TranscodingOption
 */
public struct TranscodingOptionItemKeys {
    public static let InputResolutionKey = "input_resolution"
    public static let InputFrameRateKey = "input_framerate_fps"
    public static let OutputResolutionKey = "output_resolution"
    public static let OutputFrameRateKey = "output_framerate_fps"
}

/// <#Description#>
public class TranscodingOption: SerializableItem {
    
    public var inputResolution: RecordingModeResolution = .UHD_4K
    public var inputFrameRate: UInt = 0
    public var outputResolution: RecordingModeResolution = .UHD_4K
    public var outputFrameRate: UInt = 0
    
    public init () {}
    
    /**
     Creates dictionary presentation of TranscodingOption
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        return [TranscodingOptionItemKeys.InputResolutionKey: inputResolution.rawValue,
                TranscodingOptionItemKeys.InputFrameRateKey: inputFrameRate,
                TranscodingOptionItemKeys.OutputResolutionKey: outputResolution.rawValue,
                TranscodingOptionItemKeys.OutputFrameRateKey: outputFrameRate]
    }
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")
        
        guard let inputResolutionString = serializedItem[TranscodingOptionItemKeys.InputResolutionKey] as? String else {
            log.error("\(TranscodingOptionItemKeys.InputResolutionKey) missing in dictionary")
            return false
        }

        guard let inputResolution = RecordingModeResolution(rawValue: inputResolutionString) else {
            log.error("Failed to create \(TranscodingOptionItemKeys.InputResolutionKey)")
            return false
        }

        guard let inputFrameRate = serializedItem[TranscodingOptionItemKeys.InputFrameRateKey] as? UInt else {
            log.error("\(TranscodingOptionItemKeys.InputFrameRateKey) missing in dictionary")
            return false
        }

        guard let outputResolutionString = serializedItem[TranscodingOptionItemKeys.OutputResolutionKey] as? String else {
            log.error("\(TranscodingOptionItemKeys.OutputResolutionKey) missing in dictionary")
            return false
        }

        guard let outputResolution = RecordingModeResolution(rawValue: outputResolutionString) else {
            log.error("Failed to create \(TranscodingOptionItemKeys.OutputResolutionKey)")
            return false
        }

        guard let outputFrameRate = serializedItem[TranscodingOptionItemKeys.OutputFrameRateKey] as? UInt else {
            log.error("\(TranscodingOptionItemKeys.OutputFrameRateKey) missing in dictionary")
            return false
        }

        self.inputResolution = inputResolution
        self.inputFrameRate = inputFrameRate
        self.outputResolution = outputResolution
        self.outputFrameRate = outputFrameRate
        
        return true
    }
}

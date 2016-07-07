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
 *  Set of keys for serializing and deserializing CameraCapabilities
 */
public struct CameraCapabilitiesItemKeys {
    public struct Recording {
        public static let VideoModesKey = "video"
        public static let ImageModesKey = "image"
    }
    public struct Transcoding {
        public static let TranscodersListKey = "transcoder"
    }
    public struct Scenes {
        public static let ScenesListKey = "scenes"
        public static let LimitsListKey = "limits"
    }
}

/**
 <#Description#>
 
 - parameter dictionary: <#dictionary description#>
 
 - returns: <#return value description#>
 */
public func getSupportedRecordingModesFromDictionary(dictionary: [String: AnyObject]!) -> [RecordingMode]? {
    assert(dictionary != nil, "Cannot deserialize nil into supported recording modes")
    
    guard let videoModes = dictionary[CameraCapabilitiesItemKeys.Recording.VideoModesKey] as? [[String: AnyObject]] else {
        log.error("\(CameraCapabilitiesItemKeys.Recording.VideoModesKey) missing in dictionary for supported recording modes")
        return nil
    }
    
    guard let imageModes = dictionary[CameraCapabilitiesItemKeys.Recording.ImageModesKey] as? [[String: AnyObject]] else {
        log.error("\(CameraCapabilitiesItemKeys.Recording.ImageModesKey) missing in dictionary for supported recording modes")
        return nil
    }
    
    var supportedRecordingModes: [RecordingMode] = []
    
    for videoModeDictionary in videoModes {
        let recordingMode = RecordingMode()
        
        guard recordingMode.fromDictionary(videoModeDictionary) else {
            log.error("Failed to parse video mode")
            return nil
        }
        
        supportedRecordingModes.append(recordingMode)
    }
    
    for imageModeDictionary in imageModes {
        let recordingMode = RecordingMode()
        
        guard recordingMode.fromDictionary(imageModeDictionary) else {
            log.error("Failed to parse image mode")
            return nil
        }
        
        supportedRecordingModes.append(recordingMode)
    }
    
    return supportedRecordingModes
}

/**
 <#Description#>
 
 - parameter dictionary: <#dictionary description#>
 
 - returns: <#return value description#>
 */
public func getSupportedTranscodingOptionsFromDictionary(dictionary: [String: AnyObject]!) -> [TranscodingOption]? {
    assert(dictionary != nil, "Cannot deserialize nil into supported transcoding options")
    
    guard let transcodingOptions = dictionary[CameraCapabilitiesItemKeys.Transcoding.TranscodersListKey] as? [[String: AnyObject]] else {
        log.error("\(CameraCapabilitiesItemKeys.Transcoding.TranscodersListKey) missing in dictionary for supported transcoding options")
        return nil
    }
    
    var supportedTranscodingOptions: [TranscodingOption] = []
    
    for transcodingOptionDictionary in transcodingOptions {
        let transcodingOption = TranscodingOption()
        
        guard transcodingOption.fromDictionary(transcodingOptionDictionary) else {
            log.error("Failed to parse transcoding option")
            return nil
        }
        
        supportedTranscodingOptions.append(transcodingOption)
    }
    
    return supportedTranscodingOptions
}

/**
 <#Description#>
 
 - parameter dictionary: <#dictionary description#>
 
 - returns: <#return value description#>
 */
public func getSupportedScenesFromDictionary(dictionary: [String: AnyObject]!) -> [SceneMode]? {
    assert(dictionary != nil, "Cannot deserialize nil into supported scenes")
    
    guard let sceneModes = dictionary[CameraCapabilitiesItemKeys.Scenes.ScenesListKey] as? [[String: AnyObject]] else {
        log.error("\(CameraCapabilitiesItemKeys.Scenes.ScenesListKey) missing in dictionary for supported scenes")
        return nil
    }
    
    var supportedScenes: [SceneMode] = []
    
    for sceneModeDictionary in sceneModes {
        let sceneMode = SceneMode()
        
        guard sceneMode.fromDictionary(sceneModeDictionary) else {
            log.error("Failed to parse scene mode")
            return nil
        }
        
        supportedScenes.append(sceneMode)
    }
    
    return supportedScenes
}

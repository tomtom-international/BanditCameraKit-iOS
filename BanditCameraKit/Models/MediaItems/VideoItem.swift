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
 *  Set of keys for serializing and deserializing VideoItem
 */
public struct VideoItemKeys {
    public static let DurationInSecondsKey = "length_secs"
    public static let NoOfHighlightsKey = "nr_highlights"
    public static let FramerateKey = "framerate_fps"
    public static let FrameIntervalKey = "interval_secs"
    public static let VideoHighlightsKey = "tags"
}

/// <#Description#>
public class VideoItem : MediaItem {

    public var durationInSeconds: Float = 0.0
    public var numberOfHighlights: UInt = 0
    public var creationFramerate: UInt = 0
    public var frameInterval: Float = 0.0
    public var highlights: [HighlightItem] = []
    
    /**
     <#Description#>
     
     - parameter numberOfFiles: <#numberOfFiles description#>
     
     - returns: <#return value description#>
     */
    public override init(numberOfFiles: UInt = 1) {
        super.init(numberOfFiles: numberOfFiles)
    }

    /**
     Creates dictionary presentation of VideoItem
     
     - returns: Dictionary with all properties of serialized object.
     */
    public override func toDictionary() -> [String: AnyObject] {
        var parentItem = super.toDictionary()
        
        parentItem.updateValue(durationInSeconds, forKey: VideoItemKeys.DurationInSecondsKey)
        parentItem.updateValue(numberOfHighlights, forKey: VideoItemKeys.NoOfHighlightsKey)
        parentItem.updateValue(creationFramerate, forKey: VideoItemKeys.FramerateKey)
        parentItem.updateValue(frameInterval, forKey: VideoItemKeys.FrameIntervalKey)
        
        var videoHighlights = [[String: AnyObject]]()
        
        for highlight in self.highlights {
            videoHighlights.append(highlight.toDictionary())
        }
        
        parentItem.updateValue(videoHighlights, forKey: VideoItemKeys.VideoHighlightsKey)
        
        return parentItem
    }
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public override func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")
        
        if super.fromDictionary(serializedItem) == false {
            return false
        }
        
        guard let durationInSeconds = serializedItem[VideoItemKeys.DurationInSecondsKey] as? Float else {
            log.error("\(VideoItemKeys.DurationInSecondsKey) missing in dictionary")
            return false
        }
        
        guard let numberOfHighlights = serializedItem[VideoItemKeys.NoOfHighlightsKey] as? UInt else {
            log.error("\(VideoItemKeys.NoOfHighlightsKey) missing in dictionary")
            return false
        }
        
        guard let creationFramerate = serializedItem[VideoItemKeys.FramerateKey] as? UInt else {
            log.error("\(VideoItemKeys.FramerateKey) missing in dictionary")
            return false
        }
        
        self.durationInSeconds = durationInSeconds
        self.numberOfHighlights = numberOfHighlights
        self.creationFramerate = creationFramerate

        if let frameInterval = serializedItem[VideoItemKeys.FrameIntervalKey] as? Float {
            self.frameInterval = frameInterval
        }

        if let videoHighlights = serializedItem[VideoItemKeys.VideoHighlightsKey] as? [[String: AnyObject]] {
            for highlightDictionary in videoHighlights {
                let highlightItem = HighlightItem()
                if highlightItem.fromDictionary(highlightDictionary) {
                    highlightItem.video = self
                    self.highlights.append(highlightItem)
                }
            }
        }
        
        return true
    }
}

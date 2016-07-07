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
 *  Set of keys for serializing and deserializing HighlightItem
 */
public struct HighlightItemKeys {
    public static let HighlightIdKey = "id"
    public static let OffsetInSecondsKey = "offset_secs"
    public static let HighlightOffsetInSecondsKey = "highlight_offset_secs"
    public static let HighlightDurationInSecondsKey = "highlight_length_secs"
    public static let ActualHighlightOffsetInSecondsKey = "delivered_offset_secs"
    public static let ActualHighlightDurationInSecondsKey = "delivered_length_secs"
}

/// <#Description#>
public class HighlightItem : SerializableItem {
    
    public var highlightItemId: String = ""
    public var offsetInSeconds: Float = 0.0
    public var highlightOffsetInSeconds: Float = 0.0
    public var highlightDurationInSeconds: Float = 0.0
    public var actualOffsetInSeconds: Float = 0.0
    public var actualDurationInSeconds: Float = 0.0
    public var highlightItemValue: AnyObject? = nil
    public var highlightItemName: String = ""
    public weak var video: VideoItem? = nil
    
    public init () {}
    
    /**
     Creates dictionary presentation of HighlightItem
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        return [HighlightItemKeys.HighlightIdKey : self.highlightItemId,
            HighlightItemKeys.OffsetInSecondsKey: self.offsetInSeconds,
            HighlightItemKeys.HighlightOffsetInSecondsKey: self.highlightOffsetInSeconds,
            HighlightItemKeys.HighlightDurationInSecondsKey: self.highlightDurationInSeconds,
            HighlightItemKeys.ActualHighlightOffsetInSecondsKey: self.actualOffsetInSeconds,
            HighlightItemKeys.ActualHighlightDurationInSecondsKey: self.actualDurationInSeconds,
            self.highlightItemName: self.highlightItemValue!]
    }

    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")
        
        guard let highlightItemId = serializedItem[HighlightItemKeys.HighlightIdKey] as? String else {
            log.error("\(HighlightItemKeys.HighlightIdKey) missing in dictionary")
            return false
        }
        
        guard let offsetInSeconds = serializedItem[HighlightItemKeys.OffsetInSecondsKey] as? Float else {
            log.error("\(HighlightItemKeys.OffsetInSecondsKey) missing in dictionary")
            return false
        }
        
        guard let highlightOffsetInSeconds = serializedItem[HighlightItemKeys.HighlightOffsetInSecondsKey] as? Float else {
            log.error("\(HighlightItemKeys.HighlightOffsetInSecondsKey) missing in dictionary")
            return false
        }
        
        guard let highlightDurationInSeconds = serializedItem[HighlightItemKeys.HighlightDurationInSecondsKey] as? Float else {
            log.error("\(HighlightItemKeys.HighlightDurationInSecondsKey) missing in dictionary")
            return false
        }
        
        guard let actualOffsetInSeconds = serializedItem[HighlightItemKeys.ActualHighlightOffsetInSecondsKey] as? Float else {
            log.error("\(HighlightItemKeys.ActualHighlightOffsetInSecondsKey) missing in dictionary")
            return false
        }
        
        guard let actualDurationInSeconds = serializedItem[HighlightItemKeys.ActualHighlightDurationInSecondsKey] as? Float else {
            log.error("\(HighlightItemKeys.ActualHighlightDurationInSecondsKey) missing in dictionary")
            return false
        }
        
        self.highlightItemId = highlightItemId
        self.offsetInSeconds = offsetInSeconds
        self.highlightOffsetInSeconds = highlightOffsetInSeconds
        self.highlightDurationInSeconds = highlightDurationInSeconds
        self.actualOffsetInSeconds = actualOffsetInSeconds
        self.actualDurationInSeconds = actualDurationInSeconds

        let knownKeys = [HighlightItemKeys.HighlightIdKey, HighlightItemKeys.OffsetInSecondsKey, HighlightItemKeys.HighlightOffsetInSecondsKey,
            HighlightItemKeys.HighlightDurationInSecondsKey, HighlightItemKeys.ActualHighlightDurationInSecondsKey, HighlightItemKeys.ActualHighlightOffsetInSecondsKey]

        let remainingKeys = Set(serializedItem.keys).subtract(knownKeys)
        
        for key in remainingKeys {
            if self.highlightItemName.isEmpty {
                self.highlightItemName = key
                self.highlightItemValue = serializedItem[key]
            }
            else {
                log.error("Invalid and extra key \(key) found in dictionary")
                return false
            }
        }
        
        return true
    }
}

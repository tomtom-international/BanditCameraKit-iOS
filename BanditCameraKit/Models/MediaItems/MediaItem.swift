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
 *  Set of keys for serializing and deserializing media from camera. 
 */
public struct MediaItemKeys {
    public static let IdKey = "id"
    public static let PathKey = "path"
    public static let CreationDateKey = "created"
    public static let SizeInBytesKey = "size_bytes"
    public static let CreationModeKey = "mode"
    public static let CreationResolutionKey = "resolution"
    public static let CreationAspectRatioKey = "aspect_ratio"
    public static let IsValidKey = "is_valid"
}

/**
 <#Description#>
 
 */
public enum MediaItemAspectRatio: String {
    case Normal = "4/3",
    Wide = "16/9",
    Unsupported = "unsupported"
}

/// <#Description#>
public class MediaItem : SerializableItem {
    
    public var mediaItemId: String = ""
    public var mediaItemPath: String = ""
    public var creationDate: NSDate = NSDate()
    public var creationMode: RecordingModeMode = .Unsupported
    public var creationResolution: RecordingModeResolution = .Unsupported
    public var creationAspectRatio: MediaItemAspectRatio = .Unsupported
    public var sizeInBytes: UInt = 0
    public var valid: Bool = true
    public var childItems: [MediaItem] {
        return _childItems as AnyObject as! [MediaItem]
    }
    public var numberOfFiles: UInt {
        return _numberOfFiles
    }
    public var isSession: Bool {
        return _numberOfFiles > 1
    }

    private var _childItems: NSMutableArray = NSMutableArray()
    private var _numberOfFiles: UInt
    
    /**
     <#Description#>
     
     - parameter numberOfFiles: <#numberOfFiles description#>
     
     - returns: <#return value description#>
     */
    public init(numberOfFiles: UInt = 1) {
        _numberOfFiles = numberOfFiles
    }
    
    /**
     <#Description#>
     
     - parameter item: <#item description#>
     */
    public func addItem(item: MediaItem) {
        _childItems.addObject(item)
        if _childItems.count > Int(_numberOfFiles) - 1 {
            _numberOfFiles = UInt(_childItems.count) + 1
        }
    }
    
    /**
     <#Description#>
     
     - parameter item: <#item description#>
     */
    public func removeItem(item: MediaItem) {
        removeItems([item])
    }
    
    /**
     <#Description#>
     
     - parameter items: <#items description#>
     */
    public func removeItems(items: [MediaItem]) {
        for item in items {
            _childItems.removeObject(item)
        }
        if _childItems.count < Int(_numberOfFiles) - 1 {
            _numberOfFiles = UInt(_childItems.count) + 1
        }
    }

    /**
     Creates dictionary presentation of common properties of MediaItem objects.
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        return [MediaItemKeys.PathKey : self.mediaItemPath,
            MediaItemKeys.IdKey: self.mediaItemId,
            MediaItemKeys.CreationDateKey: self.creationDate.defaultFormatterString,
            MediaItemKeys.CreationModeKey: self.creationMode.rawValue,
            MediaItemKeys.CreationResolutionKey: self.creationResolution.rawValue,
            MediaItemKeys.CreationAspectRatioKey: self.creationAspectRatio.rawValue,
            MediaItemKeys.SizeInBytesKey: self.sizeInBytes,
            MediaItemKeys.IsValidKey: self.valid]
    }
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        
        guard let mediaItemPath = serializedItem[MediaItemKeys.PathKey] as? String else {
            log.error("\(MediaItemKeys.PathKey) missing in dictionary")
            return false
        }
        
        guard let mediaItemId = serializedItem[MediaItemKeys.IdKey] as? String else {
            log.error("\(MediaItemKeys.IdKey) missing in dictionary")
            return false
        }
        
        guard let creationDateValue = serializedItem[MediaItemKeys.CreationDateKey] as? String else {
            log.error("\(MediaItemKeys.CreationDateKey) missing in dictionary")
            return false
        }
        
        guard let creationModeString = serializedItem[MediaItemKeys.CreationModeKey] as? String else {
            log.error("\(MediaItemKeys.CreationModeKey) missing in dictionary")
            return false
        }

        guard let creationResolutionString = serializedItem[MediaItemKeys.CreationResolutionKey] as? String else {
            log.error("\(MediaItemKeys.CreationResolutionKey) missing in dictionary")
            return false
        }

        guard let creationAspectRatioString = serializedItem[MediaItemKeys.CreationAspectRatioKey] as? String else {
            log.error("\(MediaItemKeys.CreationAspectRatioKey) missing in dictionary")
            return false
        }

        guard let sizeInBytes = serializedItem[MediaItemKeys.SizeInBytesKey] as? UInt else {
            log.error("\(MediaItemKeys.SizeInBytesKey) missing in dictionary")
            return false
        }
        
        if let valid = serializedItem[MediaItemKeys.IsValidKey] as? Bool {
            self.valid = valid
        }
        
        self.mediaItemPath = mediaItemPath
        self.mediaItemId = mediaItemId
        self.creationDate = creationDateValue.defaultFormatterDate!
        self.creationMode = RecordingModeMode(rawValue: creationModeString) ?? .Unsupported
        self.creationResolution = RecordingModeResolution(rawValue: creationResolutionString) ?? .Unsupported
        self.creationAspectRatio = MediaItemAspectRatio(rawValue: creationAspectRatioString) ?? .Unsupported
        self.sizeInBytes = sizeInBytes
        
        return true
    }
}

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
 *  Set of keys for serializing and deserializing ImageItem
 */
public struct ImageItemKeys {
    public static let LatitudeKey = "lat_deg"
    public static let LongitudeKey = "lon_deg"
}

/// <#Description#>
public class ImageItem : MediaItem {
    
    public var latitudeInDegrees: Float = 0.0
    public var longitudeInDegrees: Float = 0.0

    /**
     <#Description#>
     
     - parameter numberOfFiles: <#numberOfFiles description#>
     
     - returns: <#return value description#>
     */
    public override init(numberOfFiles: UInt = 1) {
        super.init(numberOfFiles: numberOfFiles)
    }
    
    /**
     Creates dictionary presentation of ImageItem
     
     - returns: Dictionary with all properties of serialized object.
     */
    public override func toDictionary() -> [String: AnyObject] {
        var parentItem = super.toDictionary()
        
        parentItem.updateValue(latitudeInDegrees, forKey: ImageItemKeys.LatitudeKey)
        parentItem.updateValue(longitudeInDegrees, forKey: ImageItemKeys.LongitudeKey)

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
        
        if let latitudeInDegrees = serializedItem[ImageItemKeys.LatitudeKey] as? Float {
            self.latitudeInDegrees = latitudeInDegrees
        }
        
        if let longitudeInDegrees = serializedItem[ImageItemKeys.LongitudeKey] as? Float {
            self.longitudeInDegrees = longitudeInDegrees
        }
        
        return true   
    }
}

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
 * SerializableItem protocol declares methods for serializing and deserializing objects. Every model that represents resource from camera implements this protocol.
 */
public protocol SerializableItem : AnyObject {
    /**
     Creates dictionary presentation of SerializableItem
     
     - returns: Dictionary with all properties of serialized object. Dictionary keys are named according to API documentation.
     */
    func toDictionary() -> [String: AnyObject]
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object. Dictionary keys are named according to API documentation.
     
     - returns: true if deserialization is successful, false otherwise
     */
    func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool
}

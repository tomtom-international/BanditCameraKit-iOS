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
 *  Set of keys for serializing and deserializing CameraFirmware
 */
public struct CameraFirmwareItemKeys {
    public static let MajorKey = "major"
    public static let MinorKey = "minor"
    public static let RevisionKey = "revision"
    public static let BuildKey = "build"
    public static let PendingMajorKey = "pending_major"
    public static let PendingMinorKey = "pending_minor"
    public static let PendingRevisionKey = "pending_revision"
    public static let PendingBuildKey = "pending_build"
}

/// <#Description#>
public class CameraFirmware: SerializableItem {

    private var _pending: CameraFirmware!
    public var pending: CameraFirmware {
        if _pending == nil {
            _pending = CameraFirmware()
            _pending.major = self.pendingMajor
            _pending.minor = self.pendingMinor
            _pending.revision = self.pendingRevision
            _pending.build = self.pendingBuild
        }
        return _pending
    }

    public var major: UInt = 0
    public var minor: UInt = 0
    public var revision: UInt = 0
    public var build: UInt = 0

    private var pendingMajor: UInt = 0
    private var pendingMinor: UInt = 0
    private var pendingRevision: UInt = 0
    private var pendingBuild: UInt = 0
    
    public init() {}

    /**
     Creates dictionary presentation of CameraFirmware
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        return [CameraFirmwareItemKeys.MajorKey : major,
            CameraFirmwareItemKeys.MinorKey : minor,
            CameraFirmwareItemKeys.RevisionKey : revision,
            CameraFirmwareItemKeys.BuildKey : build,
            CameraFirmwareItemKeys.PendingMajorKey : pending.major,
            CameraFirmwareItemKeys.PendingMinorKey : pending.minor,
            CameraFirmwareItemKeys.PendingRevisionKey : pending.revision,
            CameraFirmwareItemKeys.PendingBuildKey : pending.build]
    }
    
    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")
        
        guard let major = serializedItem[CameraFirmwareItemKeys.MajorKey] as? UInt else {
            log.error("\(CameraFirmwareItemKeys.MajorKey) missing in dictionary")
            return false
        }

        guard let minor = serializedItem[CameraFirmwareItemKeys.MinorKey] as? UInt else {
            log.error("\(CameraFirmwareItemKeys.MinorKey) missing in dictionary")
            return false
        }

        guard let revision = serializedItem[CameraFirmwareItemKeys.RevisionKey] as? UInt else {
            log.error("\(CameraFirmwareItemKeys.RevisionKey) missing in dictionary")
            return false
        }

        guard let build = serializedItem[CameraFirmwareItemKeys.BuildKey] as? UInt else {
            log.error("\(CameraFirmwareItemKeys.BuildKey) missing in dictionary")
            return false
        }

        guard let pendingMajor = serializedItem[CameraFirmwareItemKeys.PendingMajorKey] as? UInt else {
            log.error("\(CameraFirmwareItemKeys.PendingMajorKey) missing in dictionary")
            return false
        }

        guard let pendingMinor = serializedItem[CameraFirmwareItemKeys.PendingMinorKey] as? UInt else {
            log.error("\(CameraFirmwareItemKeys.PendingMinorKey) missing in dictionary")
            return false
        }

        guard let pendingRevision = serializedItem[CameraFirmwareItemKeys.PendingRevisionKey] as? UInt else {
            log.error("\(CameraFirmwareItemKeys.PendingRevisionKey) missing in dictionary")
            return false
        }

        guard let pendingBuild = serializedItem[CameraFirmwareItemKeys.PendingBuildKey] as? UInt else {
            log.error("\(CameraFirmwareItemKeys.PendingBuildKey) missing in dictionary")
            return false
        }
        
        self.major = major
        self.minor = minor
        self.revision = revision
        self.build = build
        pending.major = pendingMajor
        pending.minor = pendingMinor
        pending.revision = pendingRevision
        pending.build = pendingBuild

        return true
    }
}

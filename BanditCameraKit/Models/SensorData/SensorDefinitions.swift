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
 <#Description#>
 
 - NotSeen: <#NotSeen description#>
 - :        <# description#>
 */
public enum GPSState : String {
    case NotSeen = "NotSeen",
    NoFix = "NoFix",
    TwoDimensional = "2D",
    ThreeDimensional = "3D"
}

/**
 *  @brief <#Description#>
 */
public struct GPSData {
    public var gpsTime: Double = 0.0
    public var gpsFixState: GPSState = .NoFix
    public var speedInMetersPerSecond: Double = 0.0
    public var altitudeInMeters: Double = 0.0
    public var latitudeInDegrees: Double = 0.0
    public var longitudeInDegress: Double = 0.0
    public var heading: Double = 0.0
    public var altitudeUncertantyInMeters: Double = 0.0
    public var latitudeUncertantyInDegrees: Double = 0.0
    public var longitudeUncertantyInDegress: Double = 0.0
    
    public init() { }
}

/**
 *  @brief <#Description#>
 */
public struct Vector3D {
    public var x:Int = 0
    public var y:Int = 0
    public var z:Int = 0
    
    public init() { }
}
    
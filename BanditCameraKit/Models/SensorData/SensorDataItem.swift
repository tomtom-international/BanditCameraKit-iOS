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
 *  Set of keys for serializing and deserializing SensorDataItem
 */
public struct SensorDataKeys {
    public static let OffsetKey = "offset_msecs"
    public static let AccelerometerKey = "accel_mg"
    public static let GyroKey = "gyro_degsec"
    public static let MagnetometerKey = "magnet_mt"
    public static let PressureKey = "pressure_pa"
    
    public struct GNSS {
        public static let Key = "gnss"
        public static let GPSTimeKey = "time_secs"
        public static let GPSFixStateKey = "mode"
        public static let SpeedKey = "speed_mps"
        public static let AltitudeKey = "alt_m"
        public static let LatitudeKey = "lat_deg"
        public static let LongitudeKey = "lon_deg"
        public static let HeadingKey = "track_deg"
        public static let AltitudeUncertantyKey = "range_alt_m"
        public static let LatitudeUncertantyKey = "range_lat_m"
        public static let LongitudeUncertantyKey = "range_lon_m"
    }
    
    public static let heartRateKey = "heart_rate"
}

/// <#Description#>
public class SensorDataItem : SerializableItem {
    
    public var offsetInMiliseconds: UInt = 0
    public var accelerometerSamples: [Vector3D] = []
    public var gyroSamples: [Vector3D] = []
    public var magnetometerSamples: [Vector3D] = []
    public var pressureSamples: [Double] = []
    public var gnssSamples : [GPSData] = []
    public var heartRateSamples: [Int] = []
    
    /**
     Creates dictionary presentation of SensorDataItem
     
     - returns: Dictionary with all properties of serialized object.
     */
    public func toDictionary() -> [String: AnyObject] {
        var sensorDataDictionary: [String: AnyObject] = [SensorDataKeys.OffsetKey: offsetInMiliseconds,
                                                         SensorDataKeys.heartRateKey: heartRateSamples,
                                                         SensorDataKeys.PressureKey: pressureSamples]
        
        if accelerometerSamples.count > 0 {
            sensorDataDictionary.updateValue(convertVectorToSamples(accelerometerSamples), forKey: SensorDataKeys.AccelerometerKey)
        }
        
        if gyroSamples.count > 0 {
            sensorDataDictionary.updateValue(convertVectorToSamples(gyroSamples), forKey: SensorDataKeys.GyroKey)
        }
        
        if magnetometerSamples.count > 0 {
            sensorDataDictionary.updateValue(convertVectorToSamples(magnetometerSamples), forKey: SensorDataKeys.MagnetometerKey)
        }
        
        if gnssSamples.count > 0 {
            sensorDataDictionary.updateValue(convertVectorToSamples(magnetometerSamples), forKey: SensorDataKeys.GNSS.Key)
        }
        
        return sensorDataDictionary
    }

    /**
     Updates the object properties from values in dictionary
     
     - parameter serializedItem: Dictionary with all properties of serialized object.
     
     - returns: true if deserialization is successful, false otherwise
     */
    public func fromDictionary(serializedItem: [String: AnyObject]!) -> Bool {
        assert(serializedItem != nil, "Cannot deserialize nil into \(self.self) object")
        
        guard let offsetInMiliseconds = serializedItem[SensorDataKeys.OffsetKey] as? UInt else {
            log.error("\(SensorDataKeys.OffsetKey) missing in dictionary")
            return false
        }
        
        var sampleExists: Bool = false
        
        if let accelerometerSamples = serializedItem[SensorDataKeys.AccelerometerKey] as? [[Int]] {
            let samples = createVectorSamples(accelerometerSamples)
            if !samples.success {
                log.error("Invalid accelerometer sample")
                return false
            }
            
            self.accelerometerSamples.appendContentsOf(samples.vectorSamples)
            sampleExists = true
        }
        
        if let gyroSamples = serializedItem[SensorDataKeys.GyroKey] as? [[Int]] {
            let samples = createVectorSamples(gyroSamples)
            if !samples.success {
                log.error("Invalid gyro sample")
                return false
            }
            
            self.gyroSamples.appendContentsOf(samples.vectorSamples)
            sampleExists = true
        }
        
        if let magnetometerSamples = serializedItem[SensorDataKeys.MagnetometerKey] as? [[Int]] {
            let samples = createVectorSamples(magnetometerSamples)
            if !samples.success {
                log.error("Invalid magnetometer sample")
                return false
            }
            
            self.magnetometerSamples.appendContentsOf(samples.vectorSamples)
            sampleExists = true
        }
        
        if let pressureSamples = serializedItem[SensorDataKeys.PressureKey] as? [Double] {
            self.pressureSamples.appendContentsOf(pressureSamples)
            sampleExists = true
        }
        
        if let gnssSamples = serializedItem[SensorDataKeys.GNSS.Key] as? [[String:AnyObject]] {
            for sample in gnssSamples {
                var gnssSample: GPSData = GPSData()
                
                guard let gpsTime = sample[SensorDataKeys.GNSS.GPSTimeKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.GPSTimeKey) missing in dictionary")
                    return false
                }
                
                guard let gpsFixStateString = sample[SensorDataKeys.GNSS.GPSFixStateKey] as? String else {
                    log.error("\(SensorDataKeys.GNSS.GPSFixStateKey) missing in dictionary")
                    return false
                }
                
                guard let gpsFixState = GPSState(rawValue: gpsFixStateString) else {
                    log.error("Failed to create \(SensorDataKeys.GNSS.GPSFixStateKey)")
                    return false
                }
            
                guard let speedInMetersPerSecond = sample[SensorDataKeys.GNSS.SpeedKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.SpeedKey) missing in dictionary")
                    return false
                }

                guard let altitudeInMeters = sample[SensorDataKeys.GNSS.AltitudeKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.AltitudeKey) missing in dictionary")
                    return false
                }
                
                guard let latitudeInDegrees = sample[SensorDataKeys.GNSS.LatitudeKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.LatitudeKey) missing in dictionary")
                    return false
                }
                
                guard let longitudeInDegress = sample[SensorDataKeys.GNSS.LongitudeKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.LongitudeKey) missing in dictionary")
                    return false
                }
                
                guard let heading = sample[SensorDataKeys.GNSS.HeadingKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.HeadingKey) missing in dictionary")
                    return false
                }
                
                guard let altitudeUncertantyInMeters = sample[SensorDataKeys.GNSS.AltitudeUncertantyKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.AltitudeUncertantyKey) missing in dictionary")
                    return false
                }
                
                guard let latitudeUncertantyInDegrees = sample[SensorDataKeys.GNSS.LatitudeUncertantyKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.LatitudeUncertantyKey) missing in dictionary")
                    return false
                }
                
                guard let longitudeUncertantyInDegress = sample[SensorDataKeys.GNSS.LongitudeUncertantyKey] as? Double else {
                    log.error("\(SensorDataKeys.GNSS.LongitudeUncertantyKey) missing in dictionary")
                    return false
                }
                
                gnssSample.gpsTime = gpsTime
                gnssSample.gpsFixState = gpsFixState
                gnssSample.speedInMetersPerSecond = speedInMetersPerSecond
                gnssSample.altitudeInMeters = altitudeInMeters
                gnssSample.latitudeInDegrees = latitudeInDegrees
                gnssSample.longitudeInDegress = longitudeInDegress
                gnssSample.heading = heading
                gnssSample.altitudeUncertantyInMeters = altitudeUncertantyInMeters
                gnssSample.latitudeUncertantyInDegrees = latitudeUncertantyInDegrees
                gnssSample.longitudeUncertantyInDegress = longitudeUncertantyInDegress
                
                self.gnssSamples.append(gnssSample)
            }
            
            sampleExists = true
        }
        
        if let heartRateSamples = serializedItem[SensorDataKeys.heartRateKey] as? [Int] {
            self.heartRateSamples.appendContentsOf(heartRateSamples)
            sampleExists = true
        }
        
        if !sampleExists {
            log.error("Sensor sample is missing in dictionary")
            return false
        }
        
        self.offsetInMiliseconds = offsetInMiliseconds
        
        return true
    }
    
    /**
     <#Description#>
     
     - parameter samples: <#samples description#>
     
     - returns: <#return value description#>
     */
    private func createVectorSamples(samples:[[Int]]) -> (vectorSamples:[Vector3D], success:Bool) {
        
        var returnSamples:[Vector3D] = []
        
        for sample in samples {
            if sample.count != 3 {
                return ([], false)
            }
            
            var newSample: Vector3D = Vector3D()
            newSample.x = sample[0]
            newSample.y = sample[1]
            newSample.z = sample[2]
            
            returnSamples.append(newSample)
        }
        
        return (returnSamples, true)
    }
    
    /**
     <#Description#>
     
     - parameter vectorSamples: <#vectorSamples description#>
     
     - returns: <#return value description#>
     */
    private func convertVectorToSamples(vectorSamples:[Vector3D]) -> [[Int]] {
        var returnSamples:[[Int]] = []
        
        for vectorSample in vectorSamples {
            returnSamples.append([vectorSample.x, vectorSample.y, vectorSample.z])
        }
        
        return returnSamples
    }
    
    /**
     <#Description#>
     
     - parameter gnssSamples: <#gnssSamples description#>
     
     - returns: <#return value description#>
     */
    private func convertGnssToSamples(gnssSamples:[GPSData]) -> [[String: AnyObject]] {
        var returnSamples:[[String:AnyObject]] = []
        
        for gnssSample in gnssSamples {
            returnSamples.append([SensorDataKeys.GNSS.GPSTimeKey: gnssSample.gpsTime,
                SensorDataKeys.GNSS.GPSFixStateKey: gnssSample.gpsFixState.rawValue,
                SensorDataKeys.GNSS.SpeedKey: gnssSample.speedInMetersPerSecond,
                SensorDataKeys.GNSS.AltitudeKey: gnssSample.altitudeInMeters,
                SensorDataKeys.GNSS.LatitudeKey: gnssSample.latitudeInDegrees,
                SensorDataKeys.GNSS.LongitudeKey: gnssSample.longitudeInDegress,
                SensorDataKeys.GNSS.HeadingKey: gnssSample.heading,
                SensorDataKeys.GNSS.AltitudeUncertantyKey: gnssSample.altitudeUncertantyInMeters,
                SensorDataKeys.GNSS.LatitudeUncertantyKey: gnssSample.latitudeUncertantyInDegrees,
                SensorDataKeys.GNSS.LongitudeUncertantyKey: gnssSample.longitudeUncertantyInDegress])
        }
        
        return returnSamples
    }
}
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
 <#Description#>
 
 - parameter firmwareA: <#firmwareA description#>
 - parameter firmwareB: <#firmwareB description#>
 
 - returns: <#return value description#>
 */
public func == (firmwareA: CameraFirmware, firmwareB: CameraFirmware) -> Bool {
    return (firmwareA.major == firmwareB.major)
        && (firmwareA.minor == firmwareB.minor)
        && (firmwareA.revision == firmwareB.revision)
        && (firmwareA.build == firmwareB.build)
}

/**
 <#Description#>
 
 - parameter firmwareA: <#firmwareA description#>
 - parameter firmwareB: <#firmwareB description#>
 
 - returns: <#return value description#>
 */
public func < (firmwareA: CameraFirmware, firmwareB: CameraFirmware) -> Bool {
    if firmwareA.major < firmwareB.major {
        return true
    }
    else if firmwareA.minor < firmwareB.minor {
        return true
    }
    else if firmwareA.revision < firmwareB.revision {
        return true
    }
    else {
        return firmwareA.build < firmwareB.build
    }
}

/**
 <#Description#>
 
 - parameter firmwareA: <#firmwareA description#>
 - parameter firmwareB: <#firmwareB description#>
 
 - returns: <#return value description#>
 */
public func > (firmwareA: CameraFirmware, firmwareB: CameraFirmware) -> Bool {
    return !(firmwareA < firmwareB) && !(firmwareA == firmwareB)
}

/**
 <#Description#>
 
 - parameter firmwareA: <#firmwareA description#>
 - parameter firmwareB: <#firmwareB description#>
 
 - returns: <#return value description#>
 */
public func <= (firmwareA: CameraFirmware, firmwareB: CameraFirmware) -> Bool {
    return !(firmwareA > firmwareB)
}

/**
 <#Description#>
 
 - parameter firmwareA: <#firmwareA description#>
 - parameter firmwareB: <#firmwareB description#>
 
 - returns: <#return value description#>
 */
public func >= (firmwareA: CameraFirmware, firmwareB: CameraFirmware) -> Bool {
    return !(firmwareA < firmwareB)
}

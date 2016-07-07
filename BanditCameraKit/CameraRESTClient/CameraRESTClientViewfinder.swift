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
 *  @brief Camera viewfinder requests parametere keys
 */
public struct CameraViewfinderParameterKeys {
    public static let ViewfinderActiveKey = "viewfinder_active"
    public static let ViewfinderStreamingPortKey = "viewfinder_streaming_port"
}

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to start sending viewfinder frames
     
     - parameter receivingPort:     HTTP port for receiving viewfinder frames
     - parameter completionHandler: Called on successfull viewfinder start
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func startViewfinder(onPort receivingPort: UInt16 = CameraRESTClient.defaultViewfinderPort, _ completionHandler: () -> Void) -> RESTResponseBase {
        return setViewfinder(active: true, onPort: receivingPort, completionHandler: completionHandler)
    }
    
    /**
     Sends an HTTP request to the camera to stop sending viewfinder frames
     
     - parameter completionHandler: Called on successfull viewfinder stop
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func stopViewfinder(completionHandler: () -> Void) -> RESTResponseBase {
        return setViewfinder(active: false, completionHandler: completionHandler)
    }
    
    /**
     Sends an HTTP request to the camera to start sending viewfinder frames
     
     - parameter active:            true to start viewfinder, false to stop viewfinder
     - parameter receivingPort:     HTTP port for receiving viewfinder frames
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    private func setViewfinder(active active: Bool, onPort receivingPort: UInt16? = nil, completionHandler: () -> Void) -> RESTResponseBase {
        let recordingURL = apiRESTURLFor("viewfinder")
        var params: [String: AnyObject] = [CameraViewfinderParameterKeys.ViewfinderActiveKey : active]
        if let receivingPort = receivingPort {
            params.updateValue(UInt(receivingPort), forKey: CameraViewfinderParameterKeys.ViewfinderStreamingPortKey)
        }
        return apiRESTClient.POST(recordingURL, params: params).success(completionHandler)
    }
}

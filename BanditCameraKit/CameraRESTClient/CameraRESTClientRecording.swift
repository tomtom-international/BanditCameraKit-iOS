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
 *  @brief Camera recording requests parameter keys
 */
public struct CameraRecordingParameterKeys {
    public static let RecordingActiveKey = "recording_active"
}

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to start recording
     
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func startRecording(completionHandler: () -> Void) -> RESTResponseBase {
        return setRecording(active: true, completionHandler: completionHandler)
    }
    
    /**
     Sends an HTTP request to the camera to stop recording
     
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func stopRecording(completionHandler: () -> Void) -> RESTResponseBase {
        return setRecording(active: false, completionHandler: completionHandler)
    }
    
    /**
     Sends an HTTP request to the camera to start recording

     - parameter active:            true to start recording, false to stop recording
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    private func setRecording(active active: Bool, completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("record")
        let params = [CameraRecordingParameterKeys.RecordingActiveKey: active]
        return apiRESTClient.POST(url, params: params).success(completionHandler)
    }
}

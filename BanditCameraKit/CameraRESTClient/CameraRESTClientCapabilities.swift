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

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to get the camera recording capabilites
     
     - parameter completionHandler: Array of supported recording modes
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getRecordingCapabilities(completionHandler: (supportedRecordingModes: [RecordingMode]) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("capabilities/recording")
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get supported recording modes, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let supportedRecordingModes = getSupportedRecordingModesFromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get supported recording modes, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(supportedRecordingModes: supportedRecordingModes)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to get the camera transcoding capabilites
     
     - parameter completionHandler: Array of supported transcoding options
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getTranscodingCapabilities(completionHandler: (supportedTranscodingOptions: [TranscodingOption]) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("capabilities/transcoding")
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get supported transcoding options, response object is null"))
                response.callFailureBlock()
                return
            }

            guard let supportedTranscodingOptions = getSupportedTranscodingOptionsFromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get supported transcoding options, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(supportedTranscodingOptions: supportedTranscodingOptions)
        }

        return response
    }

    /**
     Sends an HTTP request to the camera to get the camera scene capabilites
     
     - parameter completionHandler: Array of supported scenes
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getScenesCapabilities(completionHandler: (supportedScenes: [SceneMode]) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("capabilities/scenes")
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get supported scenes, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let supportedScenes = getSupportedScenesFromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get supported scenes, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(supportedScenes: supportedScenes)
        }
        
        return response
    }
}

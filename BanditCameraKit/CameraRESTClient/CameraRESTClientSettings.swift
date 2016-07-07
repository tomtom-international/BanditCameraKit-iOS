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
     Sends an HTTP request to the camera to get current settings
     
     - parameter completionHandler: Returns camera settings object
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getSettings(completionHandler: (cameraSettings: CameraSettings) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("settings")
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera settings, response object is null"))
                response.callFailureBlock()
                return
            }
            
            let cameraSettings = CameraSettings()
            guard cameraSettings.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera settings, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(cameraSettings: cameraSettings)
        }
        
        return response
    }
    
    /**
     Sends an HTTP request to the camera to update current settings
     
     - parameter cameraSettings:    Camera settings object
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func changeSettings(cameraSettings: CameraSettings, _ completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("settings/camera")
        return apiRESTClient.PUT(url, params: cameraSettings.deviceSettingsDictionary()).success(completionHandler)
    }
    
    /**
     Sends an HTTP request to the camera to update current scene
     
     - parameter scene:             Scene object
     - parameter completionHandler: Updated scene
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func setScene(scene: SceneMode, _ completionHandler: (scene: SceneMode) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("settings/scene")
        let response = apiRESTClient.PUT(url, params: scene.toDictionary())
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to set scene, response object is null"))
                response.callFailureBlock()
                return
            }
            
            let scene = SceneMode()
            guard scene.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to set scene, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(scene: scene)
        }
        
        return response
    }
    
    /**
     Sends an HTTP request to the camera to set video mode with last used settings
     
     - parameter videoMode:         Video recording mode
     - parameter completionHandler: New video recording mode
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func setVideoMode(videoMode: RecordingMode, _ completionHandler: (videoMode: RecordingMode) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("settings/video")
        let response = apiRESTClient.PUT(url, params: videoMode.toDictionary())
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to set video mode, response object is null"))
                response.callFailureBlock()
                return
            }
            
            let videoMode = RecordingMode()
            guard videoMode.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to set video mode, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(videoMode: videoMode)
        }
        
        return response
    }
    
    /**
     Sends an HTTP request to the camera to set video mode with specified settings
     
     - parameter videoMode:         Video recording mode
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func setVideoModeWithSettings(videoMode: RecordingMode, _ completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("settings/video")
        return apiRESTClient.POST(url, params: videoMode.toDictionary()).success(completionHandler)
    }
    
    /**
     Sends an HTTP request to the camera to set image mode with last used settings
     
     - parameter videoMode:         Image recording mode
     - parameter completionHandler: New image recording mode
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func setImageMode(imageMode: RecordingMode, _ completionHandler: (imageMode: RecordingMode) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("settings/image")
        let response = apiRESTClient.PUT(url, params: imageMode.toDictionary())
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to set image mode, response object is null"))
                response.callFailureBlock()
                return
            }
            
            let imageMode = RecordingMode()
            guard imageMode.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to set image mode, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(imageMode: imageMode)
        }
        
        return response
    }
    
    /**
     Sends an HTTP request to the camera to set image mode with specified settings
     
     - parameter videoMode:         Image recording mode
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func setImageModeWithSettings(imageMode: RecordingMode, _ completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("settings/image")
        return apiRESTClient.POST(url, params: imageMode.toDictionary()).success(completionHandler)
    }
}

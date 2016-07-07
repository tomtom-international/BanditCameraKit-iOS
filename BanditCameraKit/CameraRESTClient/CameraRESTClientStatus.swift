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
     Sends an HTTP requests to the camera to get the current status
     
     - parameter completionHandler: Returns camera status object
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getStatus(completionHandler: (cameraStatus: CameraStatus) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("status")
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera status, response object is null"))
                response.callFailureBlock()
                return
            }
            
            let cameraStatus = CameraStatus()
            guard cameraStatus.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera status, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(cameraStatus: cameraStatus)
        }
        
        return response
    }
}

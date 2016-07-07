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
 *  @brief <#Description#>
 */
public struct CameraVersionParameterKeys {
    public static let VersionKey = "version"
    public static let RevisionKey = "revision"
}

private let defaultGetAPIVersionRequestTimeout: NSTimeInterval = 2

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to get the current API version and revision
     
     - parameter timeout:           Request timeout
     - parameter completionHandler: Returns API version and revision
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getAPIVersion(timeout: NSTimeInterval = defaultGetAPIVersionRequestTimeout, _ completionHandler: (version: String, revision: String) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("version")
        let response = apiRESTClient.GET(url, timeout: timeout)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera API version, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let version = responseObject[CameraVersionParameterKeys.VersionKey] as? String else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera API version, \(CameraVersionParameterKeys.VersionKey) missing in dictionary"))
                response.callFailureBlock()
                return
            }

            guard let revision = responseObject[CameraVersionParameterKeys.RevisionKey] as? String else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera API version, \(CameraVersionParameterKeys.RevisionKey) missing in dictionary"))
                response.callFailureBlock()
                return
            }

            self.apiVersion = version
            self.apiRevision = revision
            completionHandler(version: version, revision: revision)
        }
        
        return response
    }
}

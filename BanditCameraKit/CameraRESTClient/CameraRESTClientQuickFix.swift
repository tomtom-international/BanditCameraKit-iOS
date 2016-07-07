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
     Uploads new QuickGPS file to the camera
     
     - parameter fileSourcePath: Source file path
     - parameter fileName:       File name of the source file
     
     - returns: RESTUploadResponse object to enable chaining a success block, a progress block and a failure block
     */
    public func sendQuickGPS(fileSourcePath: String, fileName: String) -> RESTUploadResponse {
        let url = apiRESTURLFor("quickgpsfix")
        return apiRESTClient.upload(url, fileSourcePath: fileSourcePath, fileName: fileName)
    }

    /**
     Uploads new GLONASS file to the camera
     
     - parameter fileSourcePath: Source file path
     - parameter fileName:       File name of the source file
     
     - returns: RESTUploadResponse object to enable chaining a success block, a progress block and a failure block
     */
    public func sendGLONASS(fileSourcePath: String, fileName: String) -> RESTUploadResponse {
        let url = apiRESTURLFor("glonass")
        return apiRESTClient.upload(url, fileSourcePath: fileSourcePath, fileName: fileName)
    }
}

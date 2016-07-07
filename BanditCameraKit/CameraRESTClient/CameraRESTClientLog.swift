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
     Sends a download request to the camera to get the log file
     
     - parameter fileDestinationPath: File destination path
     
     - returns: RESTDownloadResponse object to enable chaining a progress block and a failure block
     */
    public func getLog(fileDestinationPath: String) -> RESTDownloadResponse {
        let url = apiRESTURLFor("log")
        return apiRESTClient.download(url, fileDestinationPath: fileDestinationPath, mimeType: MIMETypes.XTar)
    }
}

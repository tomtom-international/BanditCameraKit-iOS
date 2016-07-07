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

/// Response object for a download request
public class RESTDownloadResponse : RESTFileTransferResponse {
    /**
     Successful file download block
     
     - parameter completionHandler: Returns a path of the downloaded file
     
     - returns: RESTDownloadResponse object to enable chaining a progress block and a failure block
     */
    public func success(completionHandler: ((path: String) -> Void)? = nil) -> Self {
        successBlockWithFilePath = completionHandler
        
        if pendingRequestSuccessNotification {
            callSuccessBlock()
        }
        
        return self
    }

    /**
     File download progress block
     
     - parameter completionHandler: Returns the current progress in 0.1 percent steps
     
     - returns: RESTDownloadResponse object to enable chaining a success block and a failure block
     */
    public override func progress(completionHandler: ((progress: Double) -> Void)? = nil) -> RESTDownloadResponse {
        return super.progress(completionHandler) as! RESTDownloadResponse
    }
    
    /**
     Request failure block
     
     - parameter completionHandler: Returns an optional failed HTTP response and optional NSError object
     
     - returns: RESTDownloadResponse object to enable chaining a success block and a progress block
     */
    public override func failure(completionHandler: RESTResponseFailureHandler? = nil) -> RESTDownloadResponse {
        return super.failure(completionHandler) as! RESTDownloadResponse
    }
}

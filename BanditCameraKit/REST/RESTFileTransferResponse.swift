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

import Alamofire

/// Response object for a file transfer request
public class RESTFileTransferResponse : RESTResponseBase {
    
    var successBlock: (Void -> Void)? = nil
    var successBlockWithFilePath: ((path: String) -> Void)? = nil
    private let onePercent: Double = 0.01
    private var fileDestinationPath: String?
    private var progressBlock: ((progress: Double) -> Void)? = nil
    private var currentProgress: Double = 0
    
    /**
     Creates a file transfer response object
     
     - parameter request:             Underlying file transfer request
     - parameter fileDestinationPath: File transfer destination/source path
     */
    public init(request: Request?, fileDestinationPath: String? = nil) {
        super.init(request: request)
        
        self.fileDestinationPath = fileDestinationPath
    }

    /**
     NSOperation main method which sends the actual request
     */
    public override func main() {
        if let request = request {
            if startRequestImmediately {
                request.resume()
            }
            request
                .progress({ (bytesTransfered, totalBytesTransfered, totalBytesExpectedToTransfer) in
                    let progress = Double(totalBytesTransfered) / Double(totalBytesExpectedToTransfer)
                    self.callProgressBlock(progress)
                })
                .response(completionHandler: { (request, response, data, error) in
                    if response?.statusCode == HTTPStatusCodes.OK && error == nil {
                        self.callSuccessBlock()
                    }
                    else {
                        self.setFailure(response: response, error: error)
                        self.callFailureBlock()
                    }
                })
        }
        else {
            callFailureBlock()
        }
    }
    
    /**
     File transfer progress block
     
     - parameter completionHandler: Returns the current progress in 0.1 percent steps
     
     - returns: RESTFileTransferResponse object to enable chaining a success block and a failure block
     */
    public func progress(completionHandler: ((progress: Double) -> Void)? = nil) -> Self {
        progressBlock = completionHandler
        
        return self
    }
    
    /**
     Calls the file transfer success block
     */
    func callSuccessBlock() {
        if cancelled {
            return
        }
        
        callProgressBlock(1)
        
        if let successBlockWithFilePath = self.successBlockWithFilePath {
            if let fileDestinationPath = self.fileDestinationPath {
                successBlockWithFilePath(path: fileDestinationPath)
            }
        }
        else if let successBlock = self.successBlock {
            successBlock()
        }
        else {
            pendingRequestSuccessNotification = true
        }
        
        completeOperation()
    }
    
    /**
     Calls the file transfer progress block
     
     - parameter progress: Current file transfer progress
     */
    private func callProgressBlock(progress: Double) {
        if cancelled {
            return
        }

        if let progressBlock = self.progressBlock {
            if progress - currentProgress > onePercent || progress == 1 {
                currentProgress = progress
                progressBlock(progress: progress)
            }
        }
    }
}

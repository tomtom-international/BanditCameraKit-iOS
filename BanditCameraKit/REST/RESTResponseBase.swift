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

public typealias RESTResponseFailureHandler = (response: NSHTTPURLResponse?, error: NSError?) -> Void

/// Base response object for an HTTP request
public class RESTResponseBase : ConcurrentOperation {
    
    public var requestString: String {
        let method = request.request?.HTTPMethod ?? "(Unknown HTTPMethod)"
        let url = request.request?.URLString ?? "(Unknown URLString)"
        return "\(method) \(url)"
    }
    public var startRequestImmediately: Bool = true

    var request: Request!
    var pendingRequestSuccessNotification: Bool = false
    var successfulRequestResponseObject: AnyObject? = nil
    
    private var pendingRequestFailedNotification: Bool = false
    private var failedRequestResponse: NSHTTPURLResponse? = nil
    private var failedRequestError: NSError!
    private var failureBlock: RESTResponseFailureHandler? = nil
    private var failureMessageToken: dispatch_once_t = 0

    /**
     Creates a response object
     
     - parameter request: HTTP request
     */
    public init(request: Request?) {
        super.init()
        
        self.request = request
    }

    /**
     Manually sends the request
     */
    public func startRequest() {
        request.resume()
    }

    /**
     Cancels the request
     */
    public override func cancel() {
        request.cancel()
        super.cancel()
    }

    /**
     Request failure block
     
     - parameter completionHandler: Returns an optional failed HTTP response and optional NSError object
     
     - returns: RESTHTTPResponse object to enable chaining a success block
     */
    public func failure(completionHandler: RESTResponseFailureHandler? = nil) -> Self {
        failureBlock = completionHandler
        
        if pendingRequestFailedNotification {
            callFailureBlock()
        }
        
        return self
    }
    
    /**
     Sets the failure objects of the request
     
     - parameter response: HTTP URL response object, default is nil
     - parameter error:    NSError object, default is nil
     */
    public func setFailure(response response: NSHTTPURLResponse? = nil, error: NSError? = nil) {
        self.failedRequestResponse = response
        self.failedRequestError = error ?? NSError.unknownError()
    }
    
    /**
     Calls the failure block of request
     */
    public func callFailureBlock() {
        if cancelled {
            return
        }
        
        dispatch_once(&failureMessageToken) {
            if let response = self.failedRequestResponse {
                log.warning("\(self.requestString) failed with status code HTTP \(response.statusCode), failure description: \(self.failedRequestError.localizedDescription)")
            }
            else {
                log.error("\(self.requestString) failed with description: \(self.failedRequestError.localizedDescription)")
            }
        }
        
        if let failureBlock = failureBlock {
            failureBlock(response: self.failedRequestResponse, error: self.failedRequestError)
        }
        else {
            pendingRequestFailedNotification = true
        }

        self.completeOperation()
    }
}

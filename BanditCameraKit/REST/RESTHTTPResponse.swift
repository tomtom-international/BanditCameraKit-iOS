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

/**
 HTTP request response type
 
 */
public enum RESTResponseType : Int {
    case JSON,
    Data
}

/// Response object for an HTTP request
public class RESTHTTPResponse : RESTResponseBase {
    
    private var successBlockVoid: (() -> Void)? = nil
    private var successBlock: ((responseObject: AnyObject?) -> Void)? = nil
    private var successBlockJSON: ((responseObject: [String: AnyObject]?) -> Void)? = nil
    private var successBlockData: ((responseObject: NSData?) -> Void)? = nil
    private var responseType: RESTResponseType = .JSON

    /**
     NSOperation main method which sends the actual request
     */
    public override func main() {
        if let request = request {
            if startRequestImmediately {
                request.resume()
            }
            request.response(completionHandler: { (request, response, data, error) in
                if response?.statusCode == HTTPStatusCodes.OK && error == nil {
                    self.callSuccessBlock(data)
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
     Successful HTTP request block
     
     - parameter completionHandler: No return value
     
     - returns: RESTHTTPResponse object to enable chaining a failure block
     */
    public func success(completionHandler: (() -> Void)?) -> Self {
        if successBlockVoid == nil {
            successBlockVoid = completionHandler
            checkPendingRequestSuccessNotification()
        }
        
        return self
    }

    /**
     Successful HTTP request block
     
     - parameter completionHandler: Returns any object
     
     - returns: RESTHTTPResponse object to enable chaining a failure block
     */
    public func successObject(completionHandler: ((responseObject: AnyObject?) -> Void)?) -> Self {
        if successBlock == nil {
            successBlock = completionHandler
            checkPendingRequestSuccessNotification()
        }
        
        return self
    }

    /**
     Successful HTTP request block
     
     - parameter completionHandler: Returns a JSON dictionary object
     
     - returns: RESTHTTPResponse object to enable chaining a failure block
     */
    public func successJSON(completionHandler: ((responseObject: [String: AnyObject]?) -> Void)?) -> Self {
        if successBlockJSON == nil {
            successBlockJSON = completionHandler
            checkPendingRequestSuccessNotification()
        }
        
        return self
    }

    /**
     Successful HTTP request block
     
     - parameter completionHandler: Returns an NSData object
     
     - returns: RESTHTTPResponse object to enable chaining a failure block
     */
    public func successData(completionHandler: ((responseObject: NSData?) -> Void)?) -> Self {
        if successBlockData == nil {
            successBlockData = completionHandler
            responseType = .Data
            checkPendingRequestSuccessNotification()
        }
        
        return self
    }

    /**
     Request failure block
     
     - parameter completionHandler: Returns an optional failed HTTP response and optional NSError object
     
     - returns: RESTHTTPResponse object to enable chaining a success block
     */
    public override func failure(completionHandler: RESTResponseFailureHandler? = nil) -> RESTHTTPResponse {
        return super.failure(completionHandler) as! RESTHTTPResponse
    }
    
    /**
     Checks if request was complete before success block was set
     */
    private func checkPendingRequestSuccessNotification() {
        if pendingRequestSuccessNotification {
            callSuccessBlock(successfulRequestResponseObject)
        }
    }
    
    /**
     Calls the set success block
     
     - parameter responseObject: Response object if any was received
     */
    private func callSuccessBlock(responseObject: AnyObject?) {
        if cancelled {
            return
        }
        
        if let successBlockVoid = self.successBlockVoid {
            successBlockVoid()
        }
        else if let successBlock = self.successBlock {
            successBlock(responseObject: responseObject)
        }
        else if let successBlockJSON = self.successBlockJSON {
            successBlockJSON(responseObject: getResponseObjectJSON(responseObject))
        }
        else if let successBlockData = self.successBlockData {
            successBlockData(responseObject: responseObject as? NSData)
        }
        else {
            successfulRequestResponseObject = responseObject
            pendingRequestSuccessNotification = true
        }
        
        self.completeOperation()
    }
    
    /**
     Returns response object as JSON dictionary
     
     - parameter responseObject: Response object received
     
     - returns: JSON dictionary
     */
    private func getResponseObjectJSON(responseObject: AnyObject?) -> [String: AnyObject]? {
        guard let responseObjectData = responseObject as? NSData else {
            return nil
        }
        let responseObjectJSON = try? NSJSONSerialization.JSONObjectWithData(responseObjectData, options: .AllowFragments)
        return responseObjectJSON as? [String: AnyObject]
    }
}

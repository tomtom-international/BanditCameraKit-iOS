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
 *  @brief HTTP status codes
 */
public struct HTTPStatusCodes {
    public static let OK: Int = 200
    public static let BadRequest: Int = 400
    public static let NotFound: Int = 404
    public static let Conflict: Int = 409
    public static let InternalServerError: Int = 500
    public static let ServiceUnavailable: Int = 503
}

/**
 *  @brief HTTP header field names used in the SDK
 */
public struct HTTPHeaderFields {
    public static let ContentType = "Content-Type"
    public static let ContentLength = "Content-Length"
    public static let Accept = "Accept"
}

/**
 *  @brief MIME types used in the SDK
 */
public struct MIMETypes {
    public static let JPEGImage = "image/jpeg"
    public static let Binary = "binary/octet-stream"
    public static let JSON = "application/json"
    public static let XTar = "application/x-tar"
    public static let HTML = "text/html"
    public static let Zip = "application/zip"
}

/// Generic rest client to simplify requests with Alamofire
public class RESTClient {

    private static let defaultTimeoutIntervalForRequest: NSTimeInterval = 30;
    private static let defaultTimeoutIntervalForResource: NSTimeInterval = 30;

    private let requestManager: Manager
    private let imageRequestManager: Manager
    private let downloadRequestManager: Manager
    private let uploadRequestManager: Manager
    private let maximumNumberOfConcurrentConnections = 3;
    private let maximumNumberOfConcurrentConnectionsForImages = 1;
    private let requestQueue: NSOperationQueue = NSOperationQueue()
    private let imageRequestQueue: NSOperationQueue = NSOperationQueue()
    private let downloadQueue: NSOperationQueue = NSOperationQueue()
    private let uploadQueue: NSOperationQueue = NSOperationQueue()
    private let synchronizedQueue = dispatch_queue_create("synchronizedQueue", DISPATCH_QUEUE_SERIAL)
    private var fileTransferOperations: [String: RESTResponseBase] = [:]

    // MARK: Init
    
    /**
     Initializer for RESTClient class, creates specific request managers to be used for standard requests,
     image requests, download and upload
     */
    public init() {
        let requestManagerConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        requestManagerConfiguration.HTTPMaximumConnectionsPerHost = maximumNumberOfConcurrentConnections
        requestManager = Manager(configuration: requestManagerConfiguration)
        requestManager.startRequestsImmediately = false
        requestQueue.maxConcurrentOperationCount = maximumNumberOfConcurrentConnections

        let imageRequestManagerConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        imageRequestManagerConfiguration.HTTPMaximumConnectionsPerHost = maximumNumberOfConcurrentConnectionsForImages
        imageRequestManager = Manager(configuration: imageRequestManagerConfiguration)
        imageRequestManager.startRequestsImmediately = false
        imageRequestQueue.maxConcurrentOperationCount = maximumNumberOfConcurrentConnectionsForImages

        let downloadRequestManagerConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        downloadRequestManager = Manager(configuration: downloadRequestManagerConfiguration)
        downloadRequestManager.startRequestsImmediately = false

        let uploadRequestManagerConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        uploadRequestManagerConfiguration.networkServiceType = NSURLRequestNetworkServiceType.NetworkServiceTypeBackground
        uploadRequestManager = Manager(configuration: uploadRequestManagerConfiguration)
        uploadRequestManager.startRequestsImmediately = false
    }
    
    // MARK: HTTP requests
    
    /**
     Performes a GET request
     
     - parameter path:              Request path
     - parameter params:            Request parameters, default is nil
     - parameter mimeType:          Specific MIME type, default is nil
     - parameter synchronizedCalls: Performs one request at a time in synchronized order, default is false
     - parameter timeout:           Request timeout, default is 30 seconds
     
     - returns: RESTHTTPResponse object to enable chaining a success and a failure block
     */
    public func GET(path: String,
                    params: AnyObject? = nil,
                    mimeType: String? = nil,
                    synchronizedCalls: Bool = false,
                    timeout: NSTimeInterval = RESTClient.defaultTimeoutIntervalForRequest) -> RESTHTTPResponse {
        return performRequest(.GET, path: path, params: params, mimeType: mimeType, synchronizedCalls: synchronizedCalls, timeout: timeout)
    }

    /**
     Performes a POST request
     
     - parameter path:              Request path
     - parameter params:            Request parameters, default is nil
     - parameter mimeType:          Specific MIME type, default is nil
     - parameter synchronizedCalls: Performs one request at a time in synchronized order, default is false
     - parameter timeout:           Request timeout, default is 30 seconds
     
     - returns: RESTHTTPResponse object to enable chaining a success and a failure block
     */
    public func POST(path: String,
                     params: AnyObject? = nil,
                     mimeType: String? = nil,
                     synchronizedCalls: Bool = false,
                     timeout: NSTimeInterval = RESTClient.defaultTimeoutIntervalForRequest) -> RESTHTTPResponse {
        return performRequest(.POST, path: path, params: params, mimeType: mimeType, synchronizedCalls: synchronizedCalls, timeout: timeout)
    }

    /**
     Performes a PUT request
     
     - parameter path:              Request path
     - parameter params:            Request parameters, default is nil
     - parameter mimeType:          Specific MIME type, default is nil
     - parameter synchronizedCalls: Performs one request at a time in synchronized order, default is false
     - parameter timeout:           Request timeout, default is 30 seconds
     
     - returns: RESTHTTPResponse object to enable chaining a success and a failure block
     */
    public func PUT(path: String,
                    params: AnyObject? = nil,
                    mimeType: String? = nil,
                    synchronizedCalls: Bool = false,
                    timeout: NSTimeInterval = RESTClient.defaultTimeoutIntervalForRequest) -> RESTHTTPResponse {
        return performRequest(.PUT, path: path, params: params, mimeType: mimeType, synchronizedCalls: synchronizedCalls, timeout: timeout)
    }

    /**
     Performes a DELETE request
     
     - parameter path:              Request path
     - parameter params:            Request parameters, default is nil
     - parameter mimeType:          Specific MIME type, default is nil
     - parameter synchronizedCalls: Performs one request at a time in synchronized order, default is false
     - parameter timeout:           Request timeout, default is 30 seconds
     
     - returns: RESTHTTPResponse object to enable chaining a success and a failure block
     */
    public func DELETE(path: String,
                       params: AnyObject? = nil,
                       mimeType: String? = nil,
                       synchronizedCalls: Bool = false,
                       timeout: NSTimeInterval = RESTClient.defaultTimeoutIntervalForRequest) -> RESTHTTPResponse {
        return performRequest(.DELETE, path: path, params: params, mimeType: mimeType, synchronizedCalls: synchronizedCalls, timeout: timeout)
    }
    
    // MARK: Download request
    /**
     Performes a download request
     
     - parameter URL:            Request path
     - parameter fileDestinationPath: Destination file path
     - parameter mimeType:       Specific MIME type, default is nil
     - parameter timeout:       Request timeout, default is 30 seconds
            
     - returns: RESTDownloadResponse object to enable chaining a success block, a progress block and a failure block
     */
    public func download(URL: String, fileDestinationPath: String, mimeType: String? = nil, timeout: NSTimeInterval = RESTClient.defaultTimeoutIntervalForResource) -> RESTDownloadResponse {
        
        log.verbose("\(URL) \(fileDestinationPath)")
        
        var headers: [String: String] = [HTTPHeaderFields.Accept : MIMETypes.Binary]
        if let mimeType = mimeType {
            headers = [HTTPHeaderFields.Accept : mimeType]
        }
        
        let destination: Request.DownloadFileDestination = { _, _ -> NSURL in
            return NSURL(fileURLWithPath: fileDestinationPath)
        }
        
        let request = downloadRequestManager.download(.GET, URL, headers: headers, destination: destination)
        request.session.configuration.timeoutIntervalForResource = timeout
        let response = RESTDownloadResponse(request: request, fileDestinationPath: fileDestinationPath)
        fileTransferOperations.updateValue(response, forKey: URL)
        downloadQueue.addOperation(response)

        return response
    }

    /**
     Cancels an ongoing download
     
     - parameter path: Request path of the download
     */
    public func cancelDownload(path: String) {
        cancelFileTransfer(path)
    }
    
    // MARK: Upload request
    /**
     Performes an upload request
     
     - parameter URL:            Request path
     - parameter fileSourcePath: Source file path
     - parameter fileName:       Source file name
     - parameter mimeType:       Specific MIME type, default is nil
     
     - returns: RESTUploadResponse object to enable chaining a success block, a progress block and a failure block
     */
    public func upload(URL: String, fileSourcePath: String, fileName: String, mimeType: String = MIMETypes.Binary) -> RESTUploadResponse {
        
        log.verbose("\(URL) \(fileSourcePath) \(fileName)")
        
        let fileUrl = NSURL.fileURLWithPath(fileSourcePath)

        let response = RESTUploadResponse(request: nil)

        let multipartFormData: MultipartFormData -> Void = { multipartFormData in
            multipartFormData.appendBodyPart(fileURL: fileUrl, name: fileName, fileName: fileName, mimeType: mimeType)
            response.multipartFormData = multipartFormData
        }
        
        let encodingCompletion: Manager.MultipartFormDataEncodingResult -> Void = { encodingResult in
            switch encodingResult {
            case .Success(let request, _, _):
                request.session.configuration.networkServiceType = NSURLRequestNetworkServiceType.NetworkServiceTypeBackground
                response.request = request
                self.fileTransferOperations.updateValue(response, forKey: URL)
                self.uploadQueue.addOperation(response)
            case .Failure(let error):
                let description = "Upload to \(URL) failed, failed to encode \(fileSourcePath) with file name \(fileName) and MIME type \(mimeType), failure description: \(error)"
                let uploadError = NSError(domain: NSStringFromClass(self.dynamicType), code: 0, userInfo: [NSLocalizedDescriptionKey:  description])
                response.setFailure(error: uploadError)
                response.callFailureBlock()
            }
        }

        uploadRequestManager.upload(.POST, URL, multipartFormData: multipartFormData, encodingCompletion: encodingCompletion)
        
        return response
    }

    /**
     Cancels an ongoing upload
     
     - parameter path: Request path of the upload
     */
    public func cancelUpload(path: String) {
        cancelFileTransfer(path)
    }

    // MARK: HTTP requests (private)
    
    /**
     Performes an HTTP request
     
     - parameter method:            Request method
     - parameter path:              Request path
     - parameter params:            Request parameters, default is nil
     - parameter mimeType:          Specific MIME type, default is nil
     - parameter synchronizedCalls: Performs one request at a time in synchronized order, default is false
     - parameter timeout:           Request timeout, default is 30 seconds
     
     - returns: RESTHTTPResponse object to enable chaining a success and a failure block
     */
    private func performRequest(method: Alamofire.Method,
                                path: String,
                                params: AnyObject? = nil,
                                mimeType: String? = nil,
                                synchronizedCalls: Bool = false,
                                timeout: NSTimeInterval = RESTClient.defaultTimeoutIntervalForRequest) -> RESTHTTPResponse {
        
        log.verbose("\(method) \(path) \(params)")
        
        var response: RESTHTTPResponse!

        createRequest(method, path: path, params: params, mimeType: mimeType, timeout: timeout) { (request, queue) in
            if synchronizedCalls {
                dispatch_sync(self.synchronizedQueue) {
                    self.synchronizeQueueOperations(queue)
                }
            }
            
            response = RESTHTTPResponse(request: request)
            queue.addOperation(response)
        }
        
        return response
    }
    
    /**
     Creates an Alamofire Request object
     
     - parameter method:            Request method
     - parameter path:              Request path
     - parameter params:            Request params
     - parameter mimeType:          Specific MIME type
     - parameter timeout:           Request timeout
     - parameter completionHandler: Returns the Request object and operation queue based on the MIME type
     */
    private func createRequest(method: Alamofire.Method, path: String, params: AnyObject?, mimeType: String?, timeout: NSTimeInterval, completionHandler: (request: Request, queue: NSOperationQueue) -> Void) {
        var manager: Manager = requestManager
        var queue = requestQueue
        var headers: [String: String] = [HTTPHeaderFields.ContentType: MIMETypes.JSON]
        
        if let mimeType = mimeType {
            if mimeType == MIMETypes.JPEGImage {
                manager = imageRequestManager
                queue = imageRequestQueue
                headers = [HTTPHeaderFields.ContentType : mimeType]
            }
        }
        
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: path)!)
        urlRequest.HTTPMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.timeoutInterval = timeout
        
        if let params = params {
            urlRequest.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(params, options: [])
        }
        
        let request = manager.request(urlRequest)
        
        completionHandler(request: request, queue: queue)
    }
    
    /**
     Synchronizes current requests in the queue removing any pending operations
     
     - parameter queue: Requests operation queue
     */
    private func synchronizeQueueOperations(queue: NSOperationQueue) {
        if queue.operationCount > 1 {
            queue.suspended = true
            for i in (1..<queue.operationCount).reverse() {
                queue.operations[i].cancel()
            }
            queue.suspended = false
        }
    }

    // MARK: Download/upload requests (private)
    
    /**
     Cancels a file transfer request
     
     - parameter path: Request path of download/upload
     */
    private func cancelFileTransfer(path: String) {

        log.verbose(path)
        
        if let operation = fileTransferOperations[path] {
            operation.cancel()
            fileTransferOperations.removeValueForKey(path)
        }
    }
}

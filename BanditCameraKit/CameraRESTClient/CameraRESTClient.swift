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
 Sort criteria for paged requests
 */
public enum SortCriteria: String {
    case Filename = "filename"
}

/**
 Sort order for paged requests
 */
public enum SortOrder: String {
    case Ascending = "asc",
    Descending = "desc"
}

/**
 Highlights included param for Video requests
 */
public enum HighlightsIncluded: UInt {
    case No = 0,
    Yes = 1
}

/// A collection of all possible HTTP requests that can be sent to the camera
public class CameraRESTClient {
    
    public static let defaultIPAddress: String = "192.168.1.101"
    public static let defaultHTTPPort: UInt16 = 80
    public static let defaultViewfinderPort: UInt16 = 4001

    private static let errorDomain: String = "REST API calls"

    /// Current API version of the camera
    public var APIVersion: String {
        return apiVersion
    }
    
    /// Current API revision of the camera
    public var APIRevision: String {
        return apiRevision
    }

    /// Camera IP address
    public var IPAddress: String {
        return ipAddress
    }

    /// Base camera url
    public var BaseURL: String {
        return baseURL
    }

    public private(set) var apiRESTClient: RESTClient = RESTClient()
    
    var apiVersion: String = ""
    var apiRevision: String = ""

    private var ipAddress: String
    private var baseURL: String
    private var apiURL: String
    
    /**
     Creates a new camera rest client object
     
     - parameter IPAddress: Camera IP address, default is 192.168.1.101
     */
    public init(IPAddress: String = CameraRESTClient.defaultIPAddress) {
        ipAddress = IPAddress
        baseURL = "http://\(IPAddress)"
        apiURL = "\(baseURL):\(CameraRESTClient.defaultHTTPPort)/api"
    }

    /**
     Creates an API request url
     
     - parameter path:      Request path
     - parameter urlParams: Request URL parameters
     
     - returns: API request url
     */
    public func apiRESTURLFor(path: String, urlParams: [String: Any?] = [:]) -> String {
        let version = apiVersion.isEmpty ? "" : "/\(apiVersion)"
        let url = "\(apiURL)\(version)/\(path)"
        let components = NSURLComponents(string: url)!
        var queryItems: [NSURLQueryItem] = []
        for param in urlParams {
            if let value = param.1 {
                queryItems.append(NSURLQueryItem(name: param.0, value: String(value)))
            }
        }
        if queryItems.count > 0 {
            components.queryItems = queryItems
        }
        return components.URLString
    }
    
    /**
     Creates an API call error object
     
     - parameter description: Error description
     
     - returns: Error object
     */
    func getRESTClientErrorObject(description: String) -> NSError {
        return NSError(domain: CameraRESTClient.errorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey:  description])
    }
}

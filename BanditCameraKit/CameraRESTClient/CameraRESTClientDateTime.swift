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
 *  @brief Date time request parameter keys
 */
public struct CameraDateTimeParameterKeys {
    public static let DateTimeKey = "datetime"
}

extension CameraRESTClient {

    /**
     Sends an HTTP request to the camera to get the current date and time
     
     - parameter completionHandler: Camera date and time
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getDateTime(completionHandler: (dateTime: NSDate) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("datetime")
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera date and time, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let dateTimeString = responseObject[CameraDateTimeParameterKeys.DateTimeKey] as? String else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera date and time, invalid response object"))
                response.callFailureBlock()
                return
            }

            guard let dateTime = dateTimeString.defaultFormatterDate else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get camera date and time, invalid date format"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(dateTime: dateTime)
        }

        return response
    }

    /**
     Sends an HTTP request to the camera to update date and time
     
     - parameter dateTime:          New date and time
     - parameter completionHandler: Called on successful update
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func setDateTime(dateTime: NSDate, _ completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("datetime")
        let params = [CameraDateTimeParameterKeys.DateTimeKey: dateTime.defaultFormatterString]
        return apiRESTClient.POST(url, params: params).success(completionHandler)
    }
}

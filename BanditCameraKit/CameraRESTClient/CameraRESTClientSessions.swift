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
 *  @brief Camera session requests parameter keys
 */
public struct CameraSessionsParameterKeys {
    public static let TotalKey = "total"
    public static let ItemsKey = "items"
}

/**
 *  @brief Camera session requests url keys
 */
public struct CameraSessionsUrlKeys {
    public static let SortKey = "sort"
    public static let OrderKey = "order"
    public static let OffsetKey = "offset"
    public static let CountKey = "count"
}

/**
 *  @brief Camera session response object keys
 */
public struct CameraSessionsItemKeys {
    public static let NumberOfFilesKey = "number_of_files"
}

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to get the list of Video sessions
     
     - parameter sortCriteria:      Sort criteria
     - parameter order:             Sort order
     - parameter offset:            Offset 
     - parameter count:             Number of sessions
     - parameter completionHandler: List of Video objects, each the first one (or only one) in the session
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getVideoSessions(sortCriteria: SortCriteria? = nil,
                                 order: SortOrder? = nil,
                                 offset: UInt? = nil,
                                 count: UInt? = nil,
                                 completionHandler: (videoSessions: [VideoItem], totalNumberOfFiles: UInt) -> Void) -> RESTResponseBase {
        
        let urlParams: [String: Any?] = [CameraSessionsUrlKeys.SortKey: sortCriteria?.rawValue,
                                         CameraSessionsUrlKeys.OrderKey: order?.rawValue,
                                         CameraSessionsUrlKeys.OffsetKey: offset,
                                         CameraSessionsUrlKeys.CountKey: count]
        let url = apiRESTURLFor("sessions/videos", urlParams: urlParams)
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get video sessions, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let totalVideoSessions = responseObject[CameraSessionsParameterKeys.TotalKey] as? UInt else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get video sessions, \(CameraSessionsParameterKeys.TotalKey) missing in dictionary"))
                response.callFailureBlock()
                return
            }
            
            var videoSessions: [VideoItem] = []
            var totalNumberOfFiles: UInt = 0
            
            if totalVideoSessions > 0 {
                guard let items = responseObject[CameraSessionsParameterKeys.ItemsKey] as? [[String: AnyObject]] else {
                    response.setFailure(error: self.getRESTClientErrorObject("Failed to get video sessions, \(CameraSessionsParameterKeys.ItemsKey) missing in dictionary"))
                    response.callFailureBlock()
                    return
                }
                
                for videoItemDictionary in items {
                    guard let numberOfFiles = videoItemDictionary[CameraSessionsItemKeys.NumberOfFilesKey] as? UInt else {
                        response.setFailure(error: self.getRESTClientErrorObject("Failed to get video sessions, \(CameraSessionsItemKeys.NumberOfFilesKey) missing in dictionary"))
                        response.callFailureBlock()
                        return
                    }
                    
                    let videoItem = VideoItem(numberOfFiles: numberOfFiles)
                    guard videoItem.fromDictionary(videoItemDictionary) else {
                        response.setFailure(error: self.getRESTClientErrorObject("Failed to get video sessions, found an invalid video item in items list"))
                        response.callFailureBlock()
                        return
                    }

                    videoSessions.append(videoItem)
                    totalNumberOfFiles += numberOfFiles
                }
            }
            
            completionHandler(videoSessions: videoSessions, totalNumberOfFiles: totalNumberOfFiles)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to get the list of Image sessions
     
     - parameter sortCriteria:      Sort criteria
     - parameter order:             Sort order
     - parameter offset:            Offset
     - parameter count:             Number of sessions
     - parameter completionHandler: List of Image objects, each the first one (or only one) in the session
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getImageSessions(sortCriteria: SortCriteria? = nil,
                                 order: SortOrder? = nil,
                                 offset: UInt? = nil,
                                 count: UInt? = nil,
                                 completionHandler: (imageSessions: [ImageItem], totalNumberOfFiles: UInt) -> Void) -> RESTResponseBase {

        let urlParams: [String: Any?] = [CameraSessionsUrlKeys.SortKey: sortCriteria?.rawValue,
                                         CameraSessionsUrlKeys.OrderKey: order?.rawValue,
                                         CameraSessionsUrlKeys.OffsetKey: offset,
                                         CameraSessionsUrlKeys.CountKey: count]
        let url = apiRESTURLFor("sessions/images", urlParams: urlParams)
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get image sessions, response object is null"))
                response.callFailureBlock()
                return
            }

            guard let totalImageSessions = responseObject[CameraSessionsParameterKeys.TotalKey] as? UInt else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get image sessions, \(CameraSessionsParameterKeys.TotalKey) missing in dictionary"))
                response.callFailureBlock()
                return
            }

            var imageSessions: [ImageItem] = []
            var totalNumberOfFiles: UInt = 0

            if totalImageSessions > 0 {
                guard let items = responseObject[CameraSessionsParameterKeys.ItemsKey] as? [[String: AnyObject]] else {
                    response.setFailure(error: self.getRESTClientErrorObject("Failed to get image sessions, \(CameraSessionsParameterKeys.ItemsKey) missing in dictionary"))
                    response.callFailureBlock()
                    return
                }
                
                for imageItemDictionary in items {
                    guard let numberOfFiles = imageItemDictionary[CameraSessionsItemKeys.NumberOfFilesKey] as? UInt else {
                        response.setFailure(error: self.getRESTClientErrorObject("Failed to get image sessions, \(CameraSessionsItemKeys.NumberOfFilesKey) missing in dictionary"))
                        response.callFailureBlock()
                        return
                    }

                    let imageItem = ImageItem(numberOfFiles: numberOfFiles)
                    guard imageItem.fromDictionary(imageItemDictionary) else {
                        response.setFailure(error: self.getRESTClientErrorObject("Failed to get image sessions, found an invalid image item in items list"))
                        response.callFailureBlock()
                        return
                    }

                    imageSessions.append(imageItem)
                    totalNumberOfFiles += numberOfFiles
                }
            }

            completionHandler(imageSessions: imageSessions, totalNumberOfFiles: totalNumberOfFiles)
        }
        
        return response
    }
}

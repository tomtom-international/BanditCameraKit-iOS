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
 *  @brief Camera video requests parameter keys
 */
public struct CameraVideoManagementParameterKeys {
    public static let TotalKey = "total"
    public static let ItemsKey = "items"
}

/**
 *  @brief Camera video requests url keys
 */
public struct CameraVideoManagementUrlKeys {
    public static let SortKey = "sort"
    public static let OrderKey = "order"
    public static let OffsetKey = "offset"
    public static let CountKey = "count"
    public static let HighlightsKey = "tags"
    public static let OffsetSecsKey = "offset_secs"
    public static let LengthSecsKey = "length_secs"
    public static let ResolutionKey = "resolution"
    public static let FrameRateKey = "framerate"
}

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to get the list of videos
     
     - parameter sortCriteria:       Sort criteria
     - parameter order:              Sort order
     - parameter offset:             Offset
     - parameter count:              Number of videos
     - parameter highlightsIncluded: true to include Highlight objects in response
     - parameter completionHandler:  Array of Video objects
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getVideos(sortCriteria: SortCriteria? = nil,
                          order: SortOrder? = nil,
                          offset: UInt? = nil,
                          count: UInt? = nil,
                          highlightsIncluded: HighlightsIncluded? = nil,
                          completionHandler: (videos: [VideoItem]) -> Void) -> RESTResponseBase {

        let urlParams: [String: Any?] = [CameraVideoManagementUrlKeys.SortKey: sortCriteria?.rawValue,
                                         CameraVideoManagementUrlKeys.OrderKey: order?.rawValue,
                                         CameraVideoManagementUrlKeys.OffsetKey: offset,
                                         CameraVideoManagementUrlKeys.CountKey: count,
                                         CameraVideoManagementUrlKeys.HighlightsKey: highlightsIncluded?.rawValue]
        let url = apiRESTURLFor("videos", urlParams: urlParams)
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get videos, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let totalVideos = responseObject[CameraVideoManagementParameterKeys.TotalKey] as? UInt else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get videos, \(CameraVideoManagementParameterKeys.TotalKey) missing in dictionary"))
                response.callFailureBlock()
                return
            }
            
            var videos: [VideoItem] = []
            
            if totalVideos > 0 {
                guard let items = responseObject[CameraVideoManagementParameterKeys.ItemsKey] as? [[String: AnyObject]] else {
                    response.setFailure(error: self.getRESTClientErrorObject("Failed to get videos, \(CameraVideoManagementParameterKeys.ItemsKey) missing in dictionary"))
                    response.callFailureBlock()
                    return
                }
                
                for videoItemDictionary in items {
                    let videoItem = VideoItem()
                    guard videoItem.fromDictionary(videoItemDictionary) else {
                        response.setFailure(error: self.getRESTClientErrorObject("Failed to get videos, found an invalid video item in items list"))
                        response.callFailureBlock()
                        return
                    }
                    
                    videos.append(videoItem)
                }
            }
            
            completionHandler(videos: videos)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to get the video thumbnail
     
     - parameter videoId:           Video ID
     - parameter offset:            Offset of thumbnail
     - parameter synchronizedCalls: Synchronized calls, default is false
     - parameter completionHandler: Thumbnail image
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getVideoThumbnail(videoId: String, offset: Double? = nil, synchronizedCalls: Bool = false, _ completionHandler: (thumbnail: UIImage) -> Void) -> RESTResponseBase {
        let urlParams: [String: Any?] = [CameraVideoManagementUrlKeys.OffsetSecsKey: offset]
        let url = apiRESTURLFor("videos/\(videoId)/thumb", urlParams: urlParams)
        let response = apiRESTClient.GET(url, mimeType: MIMETypes.JPEGImage, synchronizedCalls: synchronizedCalls)
        
        response.successData { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get video thumbnail, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let thumbnail = UIImage(data: responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get video thumbnail, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(thumbnail: thumbnail)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to get the image from a video
     
     - parameter videoId:           Video ID
     - parameter offset:            Offset of the image
     - parameter completionHandler: Image
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getVideoImage(videoId: String, offset: Double, _ completionHandler: (image: UIImage) -> Void) -> RESTResponseBase {
        let urlParams: [String: Any?] = [CameraVideoManagementUrlKeys.OffsetSecsKey: offset]
        let url = apiRESTURLFor("videos/\(videoId)/frames", urlParams: urlParams)
        let response = apiRESTClient.GET(url, mimeType: MIMETypes.JPEGImage)
        
        response.successData { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get video image, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let image = UIImage(data: responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get video image, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(image: image)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to get the video object
     
     - parameter videoId:            Video ID
     - parameter highlightsIncluded: true to include Highlight objects in response
     - parameter completionHandler:  Video object
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getVideo(videoId: String, highlightsIncluded: HighlightsIncluded? = nil, _ completionHandler: (video: VideoItem) -> Void) -> RESTResponseBase {
        let urlParams: [String: Any?] = [CameraVideoManagementUrlKeys.HighlightsKey: highlightsIncluded]
        let url = apiRESTURLFor("videos/\(videoId)", urlParams: urlParams)
        let response = apiRESTClient.GET(url)

        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get video, response object is null"))
                response.callFailureBlock()
                return
            }
            
            let video = VideoItem()
            guard video.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get video, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(video: video)
        }
        
        return response
    }
    
    /**
     Sends a download request to the camera to download a video file
     
     - parameter videoId:             Video ID
     - parameter fileDestinationPath: File destination path
     - parameter resolution:          Requested resolution
     - parameter frameRate:           Requested framerate
     - parameter offset:              Start offset
     - parameter length:              Length of video
     
     - returns: RESTDownloadResponse object to enable chaining a progress block and a failure block
     */
    public func downloadVideo(videoId: String,
                              fileDestinationPath: String,
                              resolution: RecordingModeResolution? = nil,
                              frameRate: UInt? = nil,
                              offset: Double? = nil,
                              length: Double? = nil) -> RESTDownloadResponse {
        
        let urlParams: [String: Any?] = [CameraVideoManagementUrlKeys.ResolutionKey: resolution,
                                         CameraVideoManagementUrlKeys.FrameRateKey: frameRate,
                                         CameraVideoManagementUrlKeys.OffsetSecsKey: offset,
                                         CameraVideoManagementUrlKeys.LengthSecsKey: length]
        let url = apiRESTURLFor("videos/\(videoId)/contents", urlParams: urlParams)
        return apiRESTClient.download(url, fileDestinationPath: fileDestinationPath)
    }

    /**
     Sends an HTTP request to the camera to remove a video
     
     - parameter videoId:           Video ID
     - parameter completionHandler: Called on successfull remove
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func removeVideo(videoId: String, _ completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("videos/\(videoId)")
        return apiRESTClient.DELETE(url).success(completionHandler)
    }
}

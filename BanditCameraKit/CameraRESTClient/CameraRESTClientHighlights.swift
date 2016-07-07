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
 *  @brief Camera highlight requests parameter keys
 */
public struct CameraHighlightsParameterKeys {
    public static let ManualHighlightKey = "tag_mobile"
}

/**
 *  @brief Camera highlight requests url keys
 */
public struct CameraHighlightsUrlKeys {
    public static let ResolutionKey = "resolution"
    public static let FrameRateKey = "framerate"
}

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to get the list of highlights for a specific video
     
     - parameter videoId:           Video ID
     - parameter completionHandler: Array of video highlights
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getHighlights(videoId: String, _ completionHandler: (highlights: [HighlightItem]) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("videos/\(videoId)/tags")
        let response = apiRESTClient.GET(url)

        response.successObject { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlights, response object is null"))
                response.callFailureBlock()
                return
            }
            
            var highlights: [HighlightItem] = []
            
            guard let items = responseObject as? [[String: AnyObject]] else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlights, invalid response object"))
                response.callFailureBlock()
                return
            }

            for highlightItemDictionary in items {
                let highlightItem = HighlightItem()
                guard highlightItem.fromDictionary(highlightItemDictionary) else {
                    response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlights, found an invalid highlight item in list"))
                    response.callFailureBlock()
                    return
                }
                
                highlights.append(highlightItem)
            }
            
            completionHandler(highlights: highlights)
        }
        
        return response
    }
    
    /**
     Sends an HTTP request to the camera to create a new highlight in the video currently being recorded
     
     - parameter completionHandler: Called on successfully created highlight
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func recordHighlight(completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("record/tag")
        let params = [CameraHighlightsParameterKeys.ManualHighlightKey: true]
        return apiRESTClient.POST(url, params: params).success(completionHandler)
    }

    /**
     Sends an HTTP request to the camera to add a list of highlights to the video
     
     - parameter videoId:           Video ID
     - parameter highlights:        Array of highlights
     - parameter completionHandler: Array of added highlights
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func addHighlights(videoId: String, highlights: [HighlightItem], _ completionHandler: (highlights: [HighlightItem]) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("videos/\(videoId)/tags")
        var params: [[String: AnyObject]] = []
        
        for highlightItem in highlights {
            params.append(highlightItem.toDictionary())
        }
        
        let response = apiRESTClient.POST(url, params: params)

        response.successObject { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to add highlights, response object is null"))
                response.callFailureBlock()
                return
            }
            
            var highlights: [HighlightItem] = []
            
            guard let items = responseObject as? [[String: AnyObject]] else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to add highlights, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            for highlightItemDictionary in items {
                let highlightItem = HighlightItem()
                guard highlightItem.fromDictionary(highlightItemDictionary) else {
                    response.setFailure(error: self.getRESTClientErrorObject("Failed to add highlights, found an invalid highlight item in list"))
                    response.callFailureBlock()
                    return
                }
                
                highlights.append(highlightItem)
            }
            
            completionHandler(highlights: highlights)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to remove all highlights from a video
     
     - parameter videoId:           Video ID
     - parameter completionHandler: Called on successfull remove
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func removeHighlights(videoId: String, _ completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("videos/\(videoId)/tags")
        return apiRESTClient.DELETE(url).success(completionHandler)
    }
    
    /**
     Sends an HTTP request to the camera to get a highlight from a video
     
     - parameter videoId:           Video ID
     - parameter highlightId:       Highlight ID
     - parameter completionHandler: Highlight object
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getHighlight(videoId: String, highlightId: String, _ completionHandler: (highlight: HighlightItem) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("videos/\(videoId)/tags/\(highlightId)")
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlight, response object is null"))
                response.callFailureBlock()
                return
            }
            
            let highlightItem = HighlightItem()
            guard highlightItem.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlight, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(highlight: highlightItem)
        }
        
        return response
    }
    
    /**
     Sends an HTTP request to the camera to get update a highlight
     
     - parameter highlight:         Highlight object
     - parameter completionHandler: Updated highlight object
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func updateHighlight(highlight: HighlightItem, _ completionHandler: (highlight: HighlightItem) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("videos/\(highlight.video?.mediaItemId)/tags/\(highlight.highlightItemId)")
        let response = apiRESTClient.PUT(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlight, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard highlight.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlight, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(highlight: highlight)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to remove a highlight
     
     - parameter highlight:         Highlight object
     - parameter completionHandler: Called on successfull remove
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func removeHighlight(highlight: HighlightItem, _ completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("videos/\(highlight.video?.mediaItemId)/tags/\(highlight.highlightItemId)")
        return apiRESTClient.DELETE(url).success(completionHandler)
    }

    /**
     Sends an HTTP request to the camera to get a thumbnail for a highlight
     
     - parameter highlight:         Highlight object
     - parameter completionHandler: Thumbnail image
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getHighlightThumbnail(highlight: HighlightItem, _ completionHandler: (thumbnail: UIImage) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("videos/\(highlight.video?.mediaItemId)/tags/\(highlight.highlightItemId)")
        let response = apiRESTClient.GET(url, mimeType: MIMETypes.JPEGImage)
        
        response.successData { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlight thumbnail, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let thumbnail = UIImage(data: responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get highlight thumbnail, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(thumbnail: thumbnail)
        }
        
        return response
    }
    
    /**
     Sends a download request to the camera to download a video file representing the highlight
     
     - parameter highlight:           Highlight object
     - parameter fileDestinationPath: File destination path
     - parameter resolution:          Requested resolution, default is nil
     - parameter frameRate:           Requested framerate, default is nil
     
     - returns: RESTDownloadResponse object to enable chaining a progress block and a failure block
     */
    public func downloadHighlight(highlight: HighlightItem,
                                  fileDestinationPath: String,
                                  resolution: RecordingModeResolution? = nil,
                                  frameRate: UInt? = nil) -> RESTDownloadResponse {
        
        let urlParams: [String: Any?] = [CameraHighlightsUrlKeys.ResolutionKey: resolution,
                                         CameraHighlightsUrlKeys.FrameRateKey: frameRate]
        let url = apiRESTURLFor("videos/\(highlight.video?.mediaItemId)/tags/\(highlight.highlightItemId)/contents", urlParams: urlParams)
        return apiRESTClient.download(url, fileDestinationPath: fileDestinationPath)
    }
}

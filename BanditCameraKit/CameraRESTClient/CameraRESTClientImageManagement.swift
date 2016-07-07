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
 *  @brief Camera image requests parameter keys
 */
public struct CameraImageManagementParameterKeys {
    public static let TotalKey = "total"
    public static let ItemsKey = "items"
}

/**
 *  @brief Camera image requests url keys
 */
public struct CameraImageManagementUrlKeys {
    public static let SortKey = "sort"
    public static let OrderKey = "order"
    public static let OffsetKey = "offset"
    public static let CountKey = "count"
}

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to get the list of images
     
     - parameter sortCriteria:      Sort criteria, default is nil
     - parameter order:             Sort order, default is nil
     - parameter offset:            Offset, default is nil
     - parameter count:             Number of images to return, default is nil
     - parameter completionHandler: Array of Image objects
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getImages(sortCriteria: SortCriteria? = nil,
                          order: SortOrder? = nil,
                          offset: UInt? = nil,
                          count: UInt? = nil,
                          completionHandler: (images: [ImageItem]) -> Void) -> RESTResponseBase {

        let urlParams: [String: Any?] = [CameraImageManagementUrlKeys.SortKey: sortCriteria?.rawValue,
                                         CameraImageManagementUrlKeys.OrderKey: order?.rawValue,
                                         CameraImageManagementUrlKeys.OffsetKey: offset,
                                         CameraImageManagementUrlKeys.CountKey: count]
        let url = apiRESTURLFor("images", urlParams: urlParams)
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get images, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let totalImages = responseObject[CameraImageManagementParameterKeys.TotalKey] as? UInt else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get images, \(CameraImageManagementParameterKeys.TotalKey) missing in dictionary"))
                response.callFailureBlock()
                return
            }
            
            var images: [ImageItem] = []
            
            if totalImages > 0 {
                guard let items = responseObject[CameraImageManagementParameterKeys.ItemsKey] as? [[String: AnyObject]] else {
                    response.setFailure(error: self.getRESTClientErrorObject("Failed to get images, \(CameraImageManagementParameterKeys.ItemsKey) missing in dictionary"))
                    response.callFailureBlock()
                    return
                }
                
                for imageItemDictionary in items {
                    let imageItem = ImageItem()
                    guard imageItem.fromDictionary(imageItemDictionary) else {
                        response.setFailure(error: self.getRESTClientErrorObject("Failed to get images, found an invalid image item in items list"))
                        response.callFailureBlock()
                        return
                    }
                    
                    images.append(imageItem)
                }
            }
            
            completionHandler(images: images)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to get the thumbnail for the image
     
     - parameter imageId:           Image ID
     - parameter completionHandler: Thumbnail image
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getImageThumbnail(imageId: String, _ completionHandler: (thumbnail: UIImage) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("images/\(imageId)/thumb")
        let response = apiRESTClient.GET(url, mimeType: MIMETypes.JPEGImage)
        
        response.successData { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get image thumbnail, response object is null"))
                response.callFailureBlock()
                return
            }
            
            guard let thumbnail = UIImage(data: responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get image thumbnail, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(thumbnail: thumbnail)
        }
        
        return response
    }

    /**
     Sends an HTTP request to the camera to get the image object
     
     - parameter imageId:           Image ID
     - parameter completionHandler: Image object
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func getImage(imageId: String, _ completionHandler: (image: ImageItem) -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("images/\(imageId)")
        let response = apiRESTClient.GET(url)
        
        response.successJSON { (responseObject) in
            guard let responseObject = responseObject else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get image, response object is null"))
                response.callFailureBlock()
                return
            }
            
            let image = ImageItem()
            guard image.fromDictionary(responseObject) else {
                response.setFailure(error: self.getRESTClientErrorObject("Failed to get image, invalid response object"))
                response.callFailureBlock()
                return
            }
            
            completionHandler(image: image)
        }
        
        return response
    }

    /**
     Sends a download request to the camera to get the image
     
     - parameter imageId:             Image ID
     - parameter fileDestinationPath: File destination path
     
     - returns: RESTDownloadResponse object to enable chaining a progress block and a failure block
     */
    public func downloadImage(imageId: String, fileDestinationPath: String) -> RESTDownloadResponse {
        let url = apiRESTURLFor("images/\(imageId)/contents")
        return apiRESTClient.download(url, fileDestinationPath: fileDestinationPath)
    }
    
    /**
     Sends an HTTP request to the camera to remove an image
     
     - parameter imageId:           Image ID
     - parameter completionHandler: Called on successfull remove
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func removeImage(imageId: String, _ completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("images/\(imageId)")
        return apiRESTClient.DELETE(url).success(completionHandler)
    }
}

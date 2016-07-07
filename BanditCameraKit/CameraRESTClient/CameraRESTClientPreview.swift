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
 *  @brief Camera preview requests parameter keys
 */
public struct CameraPreviewParameterKeys {
    public static let VideoIdKey = "id"
    public static let PreviewActiveKey = "preview_active"
    public static let PreviewPortKey = "preview_port"
    public static let OffsetKey = "offset_secs"
    public static let LengthKey = "length_secs"
}

extension CameraRESTClient {
    /**
     Sends an HTTP requests to the camera to start sending preview stream to the receiver
     
     - parameter videoId:           Video ID
     - parameter previewPort:       HTTP port of the receiver
     - parameter offset:            Start offset of preview
     - parameter length:            Length of preview
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func startPreview(videoId: String, previewPort: UInt16, offset: Double? = nil, length: Double? = nil, _ completionHandler: () -> Void) -> RESTResponseBase {
        return setPreview(active: true, videoId: videoId, previewPort: previewPort, offset: offset, length: length, completionHandler: completionHandler)
    }
    
    /**
     Sends an HTTP requests to the camera to stop sending preview stream to the receiver
     
     - parameter videoId:           Video ID
     - parameter previewPort:       HTTP port of the receiver
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    public func stopPreview(videoId: String, previewPort: UInt16, _ completionHandler: () -> Void) -> RESTResponseBase {
        return setPreview(active: false, videoId: videoId, previewPort: previewPort, completionHandler: completionHandler)
    }
    
    /**
     Sends an HTTP requests to the camera to start/stop sending preview stream to the receiver
     
     - parameter active:            true to start the preview stream, false to stop the preview stream
     - parameter videoId:           Video ID
     - parameter previewPort:       HTTP port of the receiver
     - parameter offset:            Optional start offset of preview
     - parameter length:            Optionsl length of preview
     - parameter completionHandler: Called on successfull request
     
     - returns: RESTResponseBase object to enable chaining a failure block
     */
    private func setPreview(active active: Bool, videoId: String, previewPort: UInt16, offset: Double? = nil, length: Double? = nil, completionHandler: () -> Void) -> RESTResponseBase {
        let url = apiRESTURLFor("preview")
        var params: [String: AnyObject] = [CameraPreviewParameterKeys.VideoIdKey: videoId,
                                           CameraPreviewParameterKeys.PreviewActiveKey: active,
                                           CameraPreviewParameterKeys.PreviewPortKey: UInt(previewPort)]
        if let offset = offset {
            params.updateValue(offset, forKey: CameraPreviewParameterKeys.OffsetKey)
        }
        if let length = length {
            params.updateValue(length, forKey: CameraPreviewParameterKeys.LengthKey)
        }
        
        return apiRESTClient.POST(url, params: params).success(completionHandler)
    }
}

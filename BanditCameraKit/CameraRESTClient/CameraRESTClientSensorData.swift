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

extension CameraRESTClient {
    /**
     Sends an HTTP request to the camera to get the sensor data for a Video
     
     - parameter video:   Video object
     - parameter sensors: List of sensors
     - parameter offset:  Start offset in the video
     - parameter length:  Length of the video
     
     - returns: RESTHTTPResponse object to enable chaining a success block and a failure block
     */
    public func getVideoSensorData(video: VideoItem,
                                   sensors: [String]? = nil,
                                   offset: Double? = nil,
                                   length: Double? = nil) -> RESTHTTPResponse {
        let urlParams: [String: Any?] = ["filter": sensors,
                                         "offset_secs": offset,
                                         "length_secs": length]
        let url = apiRESTURLFor("videos/\(video.mediaItemId)/sensors", urlParams: urlParams)
        return apiRESTClient.GET(url)
    }
    
    /**
     Sends an HTTP request to the camera to get the sensor data file for a Video
     
     - parameter video:               Video object
     - parameter fileDestinationPath: File destination path
     - parameter sensors:             List of sensors
     - parameter offset:              Start offset in the video
     - parameter length:              Length of the video
     
     - returns: RESTDownloadResponse object to enable chaining a progress block and a failure block
     */
    public func getVideoSensorDataFile(video: VideoItem,
                                       fileDestinationPath: String,
                                       sensors: [String]? = nil,
                                       offset: Double? = nil,
                                       length: Double? = nil) -> RESTDownloadResponse {
        let urlParams: [String: Any?] = ["filter": sensors,
                                         "offset_secs": offset,
                                         "length_secs": length]
        let url = apiRESTURLFor("videos/\(video.mediaItemId)/sensors", urlParams: urlParams)
        return apiRESTClient.download(url, fileDestinationPath: fileDestinationPath)
    }
    
    /**
     Sends an HTTP request to the camera to get the sensor data for a Highlight
     
     - parameter highlight: Highlight object
     - parameter sensors:   List of sensors
     
     - returns: RESTHTTPResponse object to enable chaining a success block and a failure block
     */
    public func getHighlightSensorData(highlight: HighlightItem,
                                       sensors: [String]? = nil) -> RESTHTTPResponse {
        let urlParams: [String: Any?] = ["filter": sensors]
        let url = apiRESTURLFor("videos/\(highlight.video?.mediaItemId)/tags/\(highlight.highlightItemId)/sensors", urlParams: urlParams)
        return apiRESTClient.GET(url)
    }
    
    /**
     Sends an HTTP request to the camera to get the sensor data file for a Highlight
     
     - parameter highlight:           Highlight object
     - parameter fileDestinationPath: File destination path
     - parameter sensors:             List of sensors
     
     - returns: RESTDownloadResponse object to enable chaining a progress block and a failure block
     */
    public func getHighlightSensorDataFile(highlight: HighlightItem,
                                           fileDestinationPath: String,
                                           sensors: [String]? = nil) -> RESTDownloadResponse {
        let urlParams: [String: Any?] = ["filter": sensors]
        let url = apiRESTURLFor("videos/\(highlight.video?.mediaItemId)/tags/\(highlight.highlightItemId)/sensors", urlParams: urlParams)
        return apiRESTClient.download(url, fileDestinationPath: fileDestinationPath)
    }
}

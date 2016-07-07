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

import BanditCameraKit

extension VideoItem {
    
    var slowDownRate: UInt {
        if creationMode == .VideoSlowMotion {
            if creationResolution == .FHD_1080p {
                return 2
            }
            else if creationResolution == .HD_720p {
                return 4
            }
            else if creationResolution == .WVGA {
                return 6
            }
            return 1
        }
        return 1
    }
    
    var previewFramerate: Double {
        return Double(creationFramerate) / Double(slowDownRate)
    }
}

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

/// Preview stream receiver state delegate
public protocol PreviewStreamReceiverStateDelegate : class {
    /**
     Notifies the camera has connected to the receiver
     */
    func previewDidConnect()
    
    /**
     Notifies that start of stream has been received
     */
    func previewStartOfStreamReceived()
    
    /**
     Notifies that end of stream has been received
     */
    func previewEndOfStreamReceived()
    
    /**
     Notifies the camera has disconnected from the receiver
     */
    func previewDidDisconnect()
}

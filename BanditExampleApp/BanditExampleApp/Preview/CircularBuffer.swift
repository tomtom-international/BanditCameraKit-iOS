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

import Foundation

class CircularBuffer<T> {
    
    var canRead: Bool {
        return writingIndex - readingIndex > 0
    }
    var canWrite: Bool {
        return buffer.count - writingIndex - readingIndex > 0
    }

    private(set) var writingIndex: Int = 0
    private(set) var readingIndex: Int = 0

    private let queue = dispatch_queue_create("CircularBufferQueue", DISPATCH_QUEUE_SERIAL)
    private var buffer: [T?]!
    
    init(count: Int) {
        buffer = [T?](count: count, repeatedValue: nil)
    }
    
    func write(element: T) -> Bool {
        if canWrite {
            dispatch_sync(queue) {
                self.buffer[self.writingIndex % self.buffer.count] = element
                self.writingIndex += 1
            }
            return true
        }
        return false
    }

    func read() -> T? {
        var element: T? = nil
        if canRead {
            dispatch_sync(queue) {
                element = self.buffer[self.readingIndex % self.buffer.count]
                if element != nil {
                    self.readingIndex += 1
                }
            }
        }
        return element
    }
    
    func clear() {
        writingIndex = 0
        readingIndex = 0
        for index in 0..<buffer.count {
            buffer[index] = nil
        }
    }
}

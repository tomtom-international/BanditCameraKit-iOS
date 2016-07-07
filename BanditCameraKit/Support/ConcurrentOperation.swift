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

/// <#Description#>
public class ConcurrentOperation : NSOperation {
    
    public override var asynchronous: Bool {
        return true
    }
    
    public override var executing: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                self.willChangeValueForKey(ConcurrentOperation.isExecutingKey)
                _executing = newValue
                self.didChangeValueForKey(ConcurrentOperation.isExecutingKey)
            }
        }
    }
    
    public override var finished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                self.willChangeValueForKey(ConcurrentOperation.isFinishedKey)
                _finished = newValue
                self.didChangeValueForKey(ConcurrentOperation.isFinishedKey)
            }
        }
    }
    private static let isExecutingKey = "isExecuting"
    private static let isFinishedKey = "isFinished"
    private var _executing: Bool = false
    private var _finished: Bool = false;
    
    /**
     <#Description#>
     */
    public override func start() {
        if cancelled {
            finished = true
            return
        }
        
        executing = true
        
        main()
    }

    /**
     <#Description#>
     */
    func completeOperation() {
        executing = false
        finished  = true
    }
}

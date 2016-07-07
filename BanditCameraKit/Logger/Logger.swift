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

public let log: Logger = Logger()

public class Logger {

    public var customLogger: CustomLoggerInterface?
    
    private init() {}

    public func verbose(message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if let logger = customLogger {
            logger.verbose(message, file: file, function: function, line: line)
        }
        else {
            logMessage("VERBOSE", message: message, file: file, function: function, line: line)
        }
    }
    
    public func debug(message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if let logger = customLogger {
            logger.debug(message, file: file, function: function, line: line)
        }
        else {
            logMessage("DEBUG", message: message, file: file, function: function, line: line)
        }
    }
    
    public func info(message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if let logger = customLogger {
            logger.info(message, file: file, function: function, line: line)
        }
        else {
            logMessage("INFO", message: message, file: file, function: function, line: line)
        }
    }

    public func warning(message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if let logger = customLogger {
            logger.warning(message, file: file, function: function, line: line)
        }
        else {
            logMessage("WARNING", message: message, file: file, function: function, line: line)
        }
    }

    public func error(message: String, file: String = #file, function: String = #function, line: Int = #line) {
        if let logger = customLogger {
            logger.error(message, file: file, function: function, line: line)
        }
        else {
            logMessage("ERROR", message: message, file: file, function: function, line: line)
        }
    }
    
    private func logMessage(level: String, message: String, file: String, function: String, line: Int) {
        let timestamp = NSDate().logFormatterString
        let fileName = file.nsString.lastPathComponent
        
        print("\(timestamp) \(level) \(fileName):\(line) \(function)\n\(message)\n")
    }
}

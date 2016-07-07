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

private let defaultDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss'Z'"
private let logDateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS"
private let fileNameDateFormat: String = "yyyy.MM.dd.HH.mm.ss"
private let defaultLocaleIdentifier: String = "en_US_POSIX"

private var _defaultDateFormatter: NSDateFormatter! = nil
private var _logDateFormatter:  NSDateFormatter! = nil
private var _fileNameDateFormatter:  NSDateFormatter! = nil

public extension NSDateFormatter {
    
    public class var defaultDateFormatter : NSDateFormatter {
        if _defaultDateFormatter == nil {
            _defaultDateFormatter = NSDateFormatter()
            _defaultDateFormatter.dateFormat = defaultDateFormat
            _defaultDateFormatter.locale = NSLocale(localeIdentifier: defaultLocaleIdentifier)
        }
        
        return _defaultDateFormatter
    }

    public class var logDateFormatter : NSDateFormatter {
        if _logDateFormatter == nil {
            _logDateFormatter = NSDateFormatter()
            _logDateFormatter.dateFormat = logDateFormat
            _logDateFormatter.locale = NSLocale(localeIdentifier: defaultLocaleIdentifier)
        }
        
        return _logDateFormatter
    }

    public class var fileNameDateFormatter : NSDateFormatter {
        if _fileNameDateFormatter == nil {
            _fileNameDateFormatter = NSDateFormatter()
            _fileNameDateFormatter.dateFormat = fileNameDateFormat
            _fileNameDateFormatter.locale = NSLocale(localeIdentifier: defaultLocaleIdentifier)
        }
        
        return _fileNameDateFormatter
    }
}

public extension NSDate {
    
    var defaultFormatterString: String {
        return NSDateFormatter.defaultDateFormatter.stringFromDate(self)
    }

    var logFormatterString: String {
        return NSDateFormatter.logDateFormatter.stringFromDate(self)
    }

    var fileNameFormatterString: String {
        return NSDateFormatter.fileNameDateFormatter.stringFromDate(self)
    }
}

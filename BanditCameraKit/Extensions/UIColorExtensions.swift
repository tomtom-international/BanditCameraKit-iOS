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

extension UIColor {
    
    public var rgbString: String {
        let components = self.getRGBA()
        return "\(components.red),\(components.green),\(components.blue)"
    }
    
    public func getRGBA() -> (red: UInt, green: UInt, blue: UInt, alpha: UInt) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (UInt(red * 255), UInt(green * 255), UInt(blue * 255), UInt(alpha * 255))
    }
    
    public static func colorWithRGBA(red red: UInt, green: UInt, blue: UInt, alpha: UInt = 255) -> UIColor {
        return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
    }
}

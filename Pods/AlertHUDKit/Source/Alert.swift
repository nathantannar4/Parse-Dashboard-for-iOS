//
//  Alert.swift
//  AlertKit
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 10/19/17.
//

import UIKit

public class Alert {
    
    /// The state of an alert
    ///
    /// - transitioning: The alert is animating
    /// - active: The alert has been presented
    /// - inactive: The alert is not presented
    public enum State {
        case transitioning, active, inactive
    }
    
    
    /// The style of an alert
    public enum Style {
        case info, success, warning, danger
        
        var color: UIColor {
            switch self {
            case .info:
                return Defaults.Color.Info
            case .success:
                return Defaults.Color.Success
            case .warning:
                return Defaults.Color.Warning
            case .danger:
                return Defaults.Color.Danger
            }
        }
        
        var font: UIFont {
            switch self {
            case .info:
                return Defaults.Font.Info
            case .success:
                return Defaults.Font.Success
            case .warning:
                return Defaults.Font.Warning
            case .danger:
                return Defaults.Font.Danger
            }
        }
    }
    
    /// Holds the default values that AlertKit uses to style alerts
    public struct Defaults {
        
        public struct Color {
            
            /// The color used for alerts of Alert.Style == .info. Default is Apple's default blue tint.
            public static var Info: UIColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
            
            /// The color used for alerts of Alert.Style == .success. Default is Material Green 800
            public static var Success: UIColor = UIColor(red: 46/255, green: 125/255, blue: 50/255, alpha: 1)
            
            /// The color used for alerts of Alert.Style == .warning. Default is Material Deep Orange 600
            public static var Warning: UIColor = UIColor(red: 235/255, green: 80/255, blue: 43/255, alpha: 1)
            
            /// The color used for alerts of Alert.Style == .danger. Default is Material Red 700
            public static var Danger: UIColor = UIColor(red: 203/255, green: 45/255, blue: 53/255, alpha: 1)
        }
        
        public struct Font {
            
            /// The color used for alerts of Alert.Style == .info. Default is preferredFont(forTextStyle: .body).
            public static var Info: UIFont = UIFont.preferredFont(forTextStyle: .body)
            
            /// The color used for alerts of Alert.Style == .success. Default is preferredFont(forTextStyle: .body).
            public static var Success: UIFont = UIFont.preferredFont(forTextStyle: .body)
            
            /// The color used for alerts of Alert.Style == .warning. Default is preferredFont(forTextStyle: .body).
            public static var Warning: UIFont = UIFont.preferredFont(forTextStyle: .body)
            
            /// The color used for alerts of Alert.Style == .danger. Default is preferredFont(forTextStyle: .body).
            public static var Danger: UIFont = UIFont.preferredFont(forTextStyle: .body)
        }
    }
}

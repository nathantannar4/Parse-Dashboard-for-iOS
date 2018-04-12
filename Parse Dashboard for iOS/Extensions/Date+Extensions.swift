//
//  Date+Extensions.swift
//  Parse Dashboard for iOS
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
//  Created by Nathan Tannar on 2/12/17.
//

import Foundation

public extension Date {
    
    func addMonth(_ n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .month, value: n, to: self)!
    }
    func addDay(_ n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .day, value: n, to: self)!
    }
    func addSec(_ n: Int) -> Date {
        let cal = NSCalendar.current
        return cal.date(byAdding: .second, value: n, to: self)!
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func string(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeStyle = timeStyle
        dateFormatter.dateStyle = dateStyle
        return dateFormatter.string(from: self)
    }
    
    func timeElapsedDescription() -> String {
        let seconds = Date().timeIntervalSince(self)
        var elapsed: String
        if seconds < 60 {
            elapsed = "Just now"
        }
        else if seconds < 60 * 60 {
            let minutes = Int(seconds / 60)
            let suffix = (minutes > 1) ? "mins" : "min"
            elapsed = "\(minutes) \(suffix) ago"
        }
        else if seconds < 24 * 60 * 60 {
            let hours = Int(seconds / (60 * 60))
            let suffix = (hours > 1) ? "hours" : "hour"
            elapsed = "\(hours) \(suffix) ago"
        }
        else {
            let days = Int(seconds / (24 * 60 * 60))
            let suffix = (days > 1) ? "days" : "day"
            elapsed = "\(days) \(suffix) ago"
        }
        return elapsed
    }
    
    // MARK:- APP SPECIFIC FORMATS
    
    func dateFromString(strDate: String, format: String) -> Date? {
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let dtDate = dateFormatter.date(from: strDate){
            return dtDate as Date?
        }
        return nil
    }
    
    
    func stringify() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let strdt = dateFormatter.string(from: self as Date)
        if let dtDate = dateFormatter.date(from: strdt){
            return dateFormatter.string(from: dtDate)
        }
        return "--"
    }
    
    func stringifyTimestamp() -> String {
        return "\(self.hourTwoDigit):\(self.minuteTwoDigit) \(self.AM_PM)  \(self.monthNameShort) \(self.dayTwoDigit)"
    }
    
    
    func getUTCFormateDate(localDate: NSDate) -> String {
        
        let dateFormatter:DateFormatter = DateFormatter()
        let timeZone = NSTimeZone(name: "UTC")
        dateFormatter.timeZone = timeZone as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let dateString: String = dateFormatter.string(from: localDate as Date)
        return dateString
    }
    
    
    func combineDateWithTime(date: NSDate, time: NSDate) -> NSDate? {
        let calendar = NSCalendar.current
        
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date as Date)
        
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time as Date)
        
        
        let mergedComponments = NSDateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments as DateComponents) as NSDate?
    }
    
    func getDatesBetweenDates(startDate: Date, andEndDate endDate: Date) -> [Date] {
        let gregorian: NSCalendar = NSCalendar.current as NSCalendar;
        let components = gregorian.components(NSCalendar.Unit.day, from: startDate, to: endDate, options: [])
        var arrDates = [Date]()
        for i in 0...components.day!{
            arrDates.append(startDate.addingTimeInterval(60*60*24*Double(i)))
        }
        return arrDates
    }
    
    
    func isGreaterThanDate(_ dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func isEqualToDate(_ dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    
    // MARK:- TIME
    var timeWithAMPM: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        return dateFormatter.string(from: self as Date)
    }
    
    
    
    
    // MARK:- YEAR
    
    
    var yearFourDigit_Int: Int {
        return Int(self.yearFourDigit)!
    }
    
    var yearOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y"
        return dateFormatter.string(from: self as Date)
    }
    var yearTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"
        return dateFormatter.string(from: self as Date)
    }
    var yearFourDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self as Date)
    }
    
    
    
    // MARK:- MONTH
    
    var monthOneDigit_Int: Int {
        return Int(self.monthOneDigit)!
    }
    var monthTwoDigit_Int: Int {
        return Int(self.monthTwoDigit)!
    }
    
    
    var monthOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter.string(from: self as Date)
    }
    var monthTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameShort: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameFull: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameFirstLetter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMMM"
        return dateFormatter.string(from: self as Date)
    }
    
    // MARK:- DAY
    
    var dayOneDigit_Int: Int {
        return Int(self.dayOneDigit)!
    }
    var dayTwoDigit_Int: Int {
        return Int(self.dayTwoDigit)!
    }
    
    var dayOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self as Date)
    }
    var dayTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameShort: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameFull: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameFirstLetter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: self as Date)
    }
    
    
    
    
    // MARK:- AM PM
    var AM_PM: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a"
        return dateFormatter.string(from: self as Date)
    }
    
    // MARK:- HOUR
    
    
    var hourOneDigit_Int: Int {
        return Int(self.hourOneDigit)!
    }
    var hourTwoDigit_Int: Int {
        return Int(self.hourTwoDigit)!
    }
    var hourOneDigit24Hours_Int: Int {
        return Int(self.hourOneDigit24Hours)!
    }
    var hourTwoDigit24Hours_Int: Int {
        return Int(self.hourTwoDigit24Hours)!
    }
    var hourOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h"
        return dateFormatter.string(from: self as Date)
    }
    var hourTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh"
        return dateFormatter.string(from: self as Date)
    }
    var hourOneDigit24Hours: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H"
        return dateFormatter.string(from: self as Date)
    }
    var hourTwoDigit24Hours: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: self as Date)
    }
    
    // MARK:- MINUTE
    
    var minuteOneDigit_Int: Int {
        return Int(self.minuteOneDigit)!
    }
    var minuteTwoDigit_Int: Int {
        return Int(self.minuteTwoDigit)!
    }
    
    var minuteOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "m"
        return dateFormatter.string(from: self as Date)
    }
    var minuteTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        return dateFormatter.string(from: self as Date)
    }
    
    
    // MARK:- SECOND
    
    var secondOneDigit_Int: Int {
        return Int(self.secondOneDigit)!
    }
    var secondTwoDigit_Int: Int {
        return Int(self.secondTwoDigit)!
    }
    
    var secondOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "s"
        return dateFormatter.string(from: self as Date)
    }
    var secondTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ss"
        return dateFormatter.string(from: self as Date)
    }
}

//
//  DateExtensions.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/23/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

extension NSDateFormatter {

    /*
        Creates a data formatter that knows how to properly read RFC3339 dates which
        are sent from Kinvey.
    */
    class func rfc3339Formatter() -> NSDateFormatter {
        let en_US_POSIX = NSLocale(localeIdentifier: "en_US_POSIX")
        let rfc3339DateFormatter = NSDateFormatter()
        rfc3339DateFormatter.locale = en_US_POSIX
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        rfc3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return rfc3339DateFormatter
    }
    
}

extension NSDate {
    
    /*
        Creates an NSDate instance from a string date sent from Kinvey which follows
        the RFC3339 standard.  This uses a specific data formatter which is also
        configured to use the standard.
    */
    class func dateFromRFC3339DateString(value:String) -> NSDate? {
        let formatter = NSDateFormatter.rfc3339Formatter()
        if var date = formatter.dateFromString(value) {
            return date
        }
        return nil
    }
    
}
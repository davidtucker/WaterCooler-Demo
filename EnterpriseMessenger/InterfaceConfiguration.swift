//
//  InterfaceConfiguration.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/19/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

enum DateFormat {
    case Short
    case Long
}

class InterfaceConfiguration {
    
    class var shortDateFormatter:NSDateFormatter {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }
    
    class var longDateFormatter:NSDateFormatter {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        return formatter
    }

    class var keyColor:UIColor {
        return UIColor(red: 0.000, green: 0.847, blue: 0.522, alpha: 1.0)
    }
    
    class var contentFont:UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: 15.0)!
    }
    
    class var mainEmphasisFont:UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: 17.0)!
    }
    
    class var smallDetailFont:UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: 12.0)!
    }
    
    class var senderBubbleColor:UIColor {
        return UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1)
    }
    
    class var recipientBubbleColor:UIColor {
        return UIColor(red: 0.788, green: 0.949, blue: 0.894, alpha: 0.4)
    }
    
    class func configure() -> Void {
        configureBottomButton()
        configureTabBar()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor = InterfaceConfiguration.keyColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    class func configureBottomButton() -> Void {
        //BottomButtonView.appearance().backgroundColor = InterfaceConfiguration.keyColor
        BottomButton.appearance().setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    class func configureTabBar() {
        //UITabBar.appearance().barTintColor = UIColor(red: 100.0, green: 100.0, blue: 100.0, alpha: 1.0);
        UITabBar.appearance().tintColor = keyColor
    }
    
    class func formattedDate(format:DateFormat,date:NSDate) -> String {
        switch format {
            case .Short:
                return shortDateFormatter.stringFromDate(date)
            case .Long:
                return longDateFormatter.stringFromDate(date)
        }
    }
    
}


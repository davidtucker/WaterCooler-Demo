//
//  WaterCoolerConstants.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/13/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

struct WaterCoolerConstants {
    
    struct Config {
        
        static let AppKey = "appKey"
        static let AppSecret = "appSecret"
        
    }
    
    struct Segue {
        
        static let Signup = "SignupSegue"
        static let Login = "LoggedInSegue"
        static let AboutDetail = "ShowAboutDetail"
        
    }
    
    struct Notifications {
        
        static let UsersUpdated = "kWaterCoolerUsersUpdated"
        
        static let MessageThreadsUpdated = "kWaterCoolerThreadsUpdated"
        
        static let MessageThreadLastMessageUpdated = "kWaterCoolerMessageThreadLastMessageUpdated"
        static let MessageThreadLastMessageUpdatedUserInfoThreadIdKey = "kWaterCoolerMessageThreadLastMessageUpdatedUserInfoThreadIdKey"
        
        static let NewMessageReceived = "kWaterCoolerNewMessage"
        static let NewMessageReceivedUserInfoMessageKey = "kWaterCoolerNewMessageUserInfoMessageKey"
        
    }
}
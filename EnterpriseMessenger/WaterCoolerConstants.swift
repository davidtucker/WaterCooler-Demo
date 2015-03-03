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
        static let Logout = "LogoutSegue"
        static let ShowDirectoryDetail = "ShowDirectoryDetail"
        static let ChangePassword = "PresentChangePassword"
        static let MessagesFromDirectory = "PresentMessageFromDirectory"
        
    }
    
    struct PushNotifications {
        
        static let SenderId = "senderId"
        static let MessageText = "messageText"
        static let CreationDate = "creationDate"
        static let ThreadId = "threadId"
        static let EntityId = "entityId"
        
    }
    
    struct Notifications {
        
        static let UsersUpdated = "kWaterCoolerUsersUpdated"
        static let MessageThreadsUpdated = "kWaterCoolerThreadsUpdated"
        static let MessageThreadLastMessageUpdated = "kWaterCoolerMessageThreadLastMessageUpdated"
        static let MessageThreadLastMessageUpdatedUserInfoThreadIdKey = "kWaterCoolerMessageThreadLastMessageUpdatedUserInfoThreadIdKey"
        static let NewMessageReceived = "kWaterCoolerNewMessage"
        static let NewMessageReceivedUserInfoMessageKey = "kWaterCoolerNewMessageUserInfoMessageKey"
        
    }
    
    struct Message {
        
        static let MaximumSectionTimeVariance:Double = 900.00
        
    }
}
//
//  ObjCUtil.h
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/10/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ObjCUtil : NSObject

/*
 Normally this method would not be needed. In the early versions of Swift, the NSStringDrawingOptions
 type was mis-typed which didn't allow for a standard bitmask using Swift operators.  This shouldn't
 be needed in future versions of Swift.
 */
+ (NSStringDrawingOptions)standardStringDrawingOptions;

@end

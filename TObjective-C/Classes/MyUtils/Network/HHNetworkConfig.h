//
//  HHNetworkConfig.h
//  TAFNetworking
//
//  Created by 黑花白花 on 2017/2/11.
//  Copyright © 2017年 黑花白花. All rights reserved.
//

#ifndef HHNetworkConfig_h
#define HHNetworkConfig_h

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    HHService0,
    HHService1,
    HHService2
} HHServiceType;
#define ServiceCount 3

typedef enum : NSUInteger {
    HHServiceEnvironmentTest,
    HHServiceEnvironmentDevelop,
    HHServiceEnvironmentRelease
} HHServiceEnvironment;

#define BulidService HHService0
#define BulidServiceEnvironment HHServiceEnvironmentTest

typedef enum : NSUInteger {
    HHNetworkRequestTypeGET,
    HHNetworkRequestTypePOST
} HHNetworkRequestType;

#define RequestTimeoutInterval 8

#endif

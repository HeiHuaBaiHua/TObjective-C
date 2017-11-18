#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "RealReachability.h"
#import "LocalConnection.h"
#import "PingHelper.h"

FOUNDATION_EXPORT double RealReachabilityVersionNumber;
FOUNDATION_EXPORT const unsigned char RealReachabilityVersionString[];


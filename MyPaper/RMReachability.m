//
//  RMReachability.m
//  MyPaper
//
//  Created by leave on 14-7-17.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import "RMReachability.h"

#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

/**
 *  all code copied from "Reachability"
 */

typedef NS_ENUM (NSInteger, NetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    NotReachable = 0,
    ReachableViaWiFi = 2,
    ReachableViaWWAN = 1
};

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

@interface RMReachability ()
@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@property (nonatomic, assign) BOOL                     reachableOnWWAN;
@end

@implementation RMReachability

+ (instancetype)reachabilityForInternetConnection
{
    struct sockaddr_in zeroAddress;

    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    return [self reachabilityWithAddress:&zeroAddress];
}

+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);

    if (ref) {
        id reachability = [[self alloc] initWithReachabilityRef:ref];

        return reachability;
    }

    return nil;
}

- (instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref
{
    self = [super init];

    if (self != nil) {
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;
    }

    return self;
}

- (NetworkStatus)currentReachabilityStatus
{
    if ([self isReachable]) {
        if ([self isReachableViaWiFi]) {
            return ReachableViaWiFi;
        }

#if TARGET_OS_IPHONE
            return ReachableViaWWAN;
#endif
    }

    return NotReachable;
}

- (BOOL)isReachable
{
    SCNetworkReachabilityFlags flags;

    if (!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        return NO;
    }

    return [self isReachableWithFlags:flags];
}

- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL connectionUP = YES;

    if (!(flags & kSCNetworkReachabilityFlagsReachable)) {
        connectionUP = NO;
    }

    if ((flags & testcase) == testcase) {
        connectionUP = NO;
    }

#if TARGET_OS_IPHONE
        if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
            // We're on 3G.
            if (!self.reachableOnWWAN) {
                // We don't want to connect when on 3G.
                connectionUP = NO;
            }
        }
#endif

    return connectionUP;
}

- (BOOL)isReachableViaWiFi
{
    SCNetworkReachabilityFlags flags = 0;

    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        // Check we're reachable
        if ((flags & kSCNetworkReachabilityFlagsReachable)) {
#if TARGET_OS_IPHONE
                // Check we're NOT on WWAN
                if ((flags & kSCNetworkReachabilityFlagsIsWWAN)) {
                    return NO;
                }
#endif
            return YES;
        }
    }

    return NO;
}


+ (BOOL)isConnectedViaWifi{
    RMReachability *reachability = [self reachabilityForInternetConnection];
    NetworkStatus status = [reachability currentReachabilityStatus];
    return status == ReachableViaWiFi;
}


@end
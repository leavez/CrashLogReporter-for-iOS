//
//  RMSystemInfoNonAsyncSafe.m
//  RenrenMonitor
//
//  Created by leave on 14-7-8.
//  Copyright (c) 2014年 renren. All rights reserved.
//

#import "RMSystemInfoNonAsyncSafe.h"


battery_info_struct_t getBatteryLevelAndState()
{
    UIDevice* device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    int batteryLevel = [device batteryLevel] * 100;
    int batteryState = [device batteryState];
    battery_info_struct_t batteryInfo;
    batteryInfo.batteryLevel = batteryLevel;
    batteryInfo.batteryState = batteryState;
    return batteryInfo;
}

int getProximityState()
{
    UIDevice *device = [UIDevice currentDevice];
    [device setProximityMonitoringEnabled:YES];
    return device.proximityState ? 1 : 0;
}



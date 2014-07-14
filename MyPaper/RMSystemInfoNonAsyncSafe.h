//
//  RMSystemInfoNonAsyncSafe.h
//  RenrenMonitor
//
//  Created by leave on 14-7-8.
//  Copyright (c) 2014年 renren. All rights reserved.
//


#ifndef RenrenMonitor_RMSystemInfo_NonAsyncSafe_h
#define RenrenMonitor_RMSystemInfo_NonAsyncSafe_h

/**
 * 存储电池信息
 *
 * @param batteryLevel 电量的百分百
 * @param batteryState 电池状态：充电，充满，不在充电
 *
 * 系统只提供5%的精度
 */
typedef struct battery_info_struct {
    unsigned int         batteryLevel;
    UIDeviceBatteryState batteryState;
} battery_info_struct_t;

/**
 * 获得电池电量信息和电池状态
 *
 * @return battery_info_struct_t 结构体
 */
battery_info_struct_t getBatteryLevelAndState();

/**
 * 获得距离传感器状态
 *
 * @return 1为靠近，0为无东西靠近
 */
int getProximityState();

#endif
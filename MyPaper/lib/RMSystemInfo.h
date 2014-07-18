//
//  RMSystemInfo.h
//  RenrenMonitor
//
//  Created by leave on 14-7-8.
//  Copyright (c) 2014年 renren. All rights reserved.
//

#ifndef RenrenMonitor_RMSystemInfo_h
#define RenrenMonitor_RMSystemInfo_h

#import <mach/mach.h>
#import <mach/mach_host.h>

/**
 * 存储磁盘信息
 *
 * @param freeBytes 可用磁盘空间 单位：MB
 * @param totalBytes 总磁盘空间 单位：MB
 */
typedef struct disk_info_struct{
    float freeBytes;
    float totalBytes;
}disk_info_struct_t;

/**
 * 存储RAM信息
 *
 * @discussion 没有包括硬件占用的ram。比如手机1G的RAM在这里可能只显示成700多m
 *
 * @param freeMem 可用RAM 单位：MB
 * @param usedMem 已用RAM 单位：MB
 * @param totalMem 总RAM 单位：MB
 */
typedef struct mem_info_struct {
    float freeMem;
    float usedMem;
    float totalMem;
} mem_info_struct_t;




/**
 * 获得越狱状态
 *
 * 判断的方法是通过系统路径
 *
 * @return 0为未越狱 1为越狱
 */
int is_jailbroken();

/**
 * 获得磁盘信息
 */
disk_info_struct_t  get_disk_info();

/**
 * 获得RAM信息
 */
mem_info_struct_t get_RAM_info();

/**
 * 获得cpu使用量信息
 *
 * @return cpu占用百分比
 */
float cpu_usage();

#endif

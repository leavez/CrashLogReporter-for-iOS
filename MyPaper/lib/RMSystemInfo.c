//
//  RMSystemInfo.c
//  RenrenMonitor
//
//  Created by leave on 14-7-8.
//  Copyright (c) 2014年 renren. All rights reserved.
//

#define IN_MB (1024.*1024.)

#include "RMSystemInfo.h"

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <mach/mach.h>

#pragma mark - pure C

/* jailbroken */

int is_jailbroken()
{
    int file = open("/bin/bash", O_NONBLOCK);
    int isbashExist = 0;
    if (file >= 0) {
        // Device is jailbroken
        isbashExist = 1;
    }
    return isbashExist;
}

/* disk info */

disk_info_struct_t get_disk_info()
{
    struct statfs tStatfs;
    statfs("/private/var", &tStatfs); // NOTICE: statfs doesn't guarantee Async-safe
    unsigned long long totalBlocks = tStatfs.f_blocks;
    unsigned long long freeBlocks_userAvaliable = tStatfs.f_bavail;  // free blocks avail to non-superuser.  almost the same as f_bfree
    unsigned long long totalBytes = totalBlocks * tStatfs.f_bsize;
    unsigned long long freeByetes = freeBlocks_userAvaliable * tStatfs.f_bsize;

    disk_info_struct_t resultInfo;
    resultInfo.totalBytes = totalBytes / IN_MB;
    resultInfo.freeBytes = freeByetes / IN_MB;

    return resultInfo;
}

/* RAM info */

mem_info_struct_t get_RAM_info()
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);

    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        //printf("Failed to fetch vm statistics");
    }

    /* Stats in bytes */
    unsigned long mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
    unsigned long mem_free = vm_stat.free_count * pagesize;
    unsigned long mem_total = mem_used + mem_free;

    mem_info_struct_t resultInfo;
    resultInfo.freeMem = mem_free / IN_MB;
    resultInfo.usedMem = mem_used / IN_MB;
    resultInfo.totalMem = mem_total / IN_MB;
    return resultInfo;
}

/* CPU usage */

float cpu_usage()
{
    kern_return_t          kr;
    task_info_data_t       tinfo;
    mach_msg_type_number_t task_info_count;

    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);

    if (kr != KERN_SUCCESS) {
        return -1;
    }

    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;

    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;

    thread_basic_info_t basic_info_th;
    uint32_t            stat_thread = 0; // Mach threads

    basic_info = (task_basic_info_t)tinfo;

    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);

    if (kr != KERN_SUCCESS) {
        return -1;
    }

    if (thread_count > 0) {
        stat_thread += thread_count;
    }

    long  tot_sec = 0;
    long  tot_usec = 0;
    float tot_cpu = 0;

    // for each thread
    for (int i = 0; i < thread_count; ++i) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[i], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);

        if (kr != KERN_SUCCESS) {
            return -1;
        }

        basic_info_th = (thread_basic_info_t)thinfo;

        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    }

    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    
    return tot_cpu;
}

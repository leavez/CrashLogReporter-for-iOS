//
//  RMThreadName.h
//  RenrenMonitor
//
//  Created by zhaodg on 14-6-16.
//  Copyright (c) 2014年 renren. All rights reserved.
//


/**
 * get_thread_names函数返回的结构体
 *
 * @param all_names_array 指向一个数组的指针，数组里存了每个线程的名的字符串
 * @param count 指向的数组的长度
 */
typedef struct {
    char **all_names_array;
    unsigned count;
} thread_name_array_t;

/**
 * 获得线程的名字。
 * 线程名一种是Unix的线程的名字，一种是dispach_queue的名字，据观察两者不同时存在，以前者优先
 *
 * @return thread_name_array_t结构体，包含了线程的名字的一些信息，用完要手工free掉。
 */
thread_name_array_t get_thread_names();


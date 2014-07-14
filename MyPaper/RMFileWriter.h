//
//  RHCWriteCAPI.h
//  writeCDemo
//
//  Created by leave on 14-1-10.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#include "RMThreadName.h"

#ifndef writeCDemo_RHCWriteCAPI_h
#define writeCDemo_RHCWriteCAPI_h
/**
 * 写文件
 *
 * @param path c字符串，写入目录，带文件名
 * @param fileName c字符串 属性的名称（比如，batteryPercent）
 * @param data 写入的二进制数据
 *
 * @return 写入的字节数 -1为error
 */
ssize_t writeByte (const char* pathWithFilename ,const char* propertyName, const char* data);

/**
 * 把一个unsinged int 写入文件
 *
 * @param path c字符串，写入目录，带文件名
 * @param fileName c字符串 属性的名称（比如，batteryPercent）
 * @param value unsigned int 写入的值
 *
 * @return 写入的字节数 -1为error
 */

ssize_t writeUnsignInt(const char* pathWithFilename ,const char* propertyName, unsigned int value);

/**
 * 把线程名结构体 写入文件
 *
 * @param path c字符串，写入目录，带文件名
 * @param names 存着线程名
 *
 * @return 写入的字节数 -1为error
 */
 
ssize_t writeThreadNames (const char* pathWithFilename, thread_name_array_t names);

#endif

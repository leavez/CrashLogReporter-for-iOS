//
//  RMCrashReportFomatter.h
//  MyPaper
//
//  Created by leave on 14-7-15.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMCrashReportFomatter : NSObject

/*
 *  把protobuf的log数据转换成text，并为每个线程加上名字。
 *
 *  @return NSString，带线程名的文字版crashlog
 */
+ (NSString *)textLogForCrashData:(NSData*)data threadNames:(NSArray*)names;

@end

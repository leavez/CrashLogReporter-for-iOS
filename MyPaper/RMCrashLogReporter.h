//
//  RMCrashLogReporter.h
//  MyPaper
//
//  Created by leave on 14-7-1.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultServerURL @"http://10.2.45.68:8080/crash-store/crashlog/uploadCrashLog"

@class RMConfig;
@protocol RMCrashLogReporterConfigDataSource <NSObject>
@required
- (RMConfig *)crashLogReporterConfig;
@end

@interface RMCrashLogReporter : NSObject
@property (nonatomic,weak) id<RMCrashLogReporterConfigDataSource> delegate;

/**
 * All-in-One 初始化方法。
 * 包括：1 注册crash后的处理服务，2 检查并发送已有的crashlog
 * 默认延迟1s执行，以防阻碍程序启动
 */
+ (void)registerServiceWithDelegate:(id<RMCrashLogReporterConfigDataSource>)delegate;
+ (void)registerServiceWithDelegate:(id<RMCrashLogReporterConfigDataSource>)delegate afterDelay:(NSTimeInterval)delay;

@end



@interface RMConfig : NSObject

/* 
 *  Set your own server URL.
 *  default value will be use if not set
 */
@property (nonatomic, copy) NSString *serverURL;

/*
 *  Other info that will be sent to server
 *  provide more info to help developer
 *  optional.
 */
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *otherInfo;

/*
 *  Custom value for app info when send to crash log server.
 *  If they are not set manually, proper value will be use when sending.
 *  optional.
 */
@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *build;


/*
 *  Strategy
 */

// if YES， 只有在wifi的情况下，才会提示是否发送log。自动发送上次发送失败的log也要等待wifi情况。
// if NO, 会把文件存在另一文件夹里，等待有新crash的时候一起发送。default value NO
@property (nonatomic, assign) BOOL onlySendInWifi;

// 在用户在提示发送时选择cancel，是否删除crash文件，如果NO，会吧crash存在另一个文件夹里
// 等待在另一个新的crash产生时一起发送
// default value is NO
@property (nonatomic, assign) BOOL shouldDeleteCrashWhenPressCancel;
@property (nonatomic, assign) BOOL shouldAutoSubmitCrashReport;
@property (nonatomic, assign) BOOL shouldCheckCrashHandlerNotModifiedByOthers; // only work in debug mode

@end

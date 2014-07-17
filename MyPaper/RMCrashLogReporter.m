//
//  RMCrashLogReporter.m
//  MyPaper
//
//  Created by leave on 14-7-1.
//  Copyright (c) 2014年 leave. All rights reserved.
//



#import "RMCrashLogReporter.h"
#import <CrashReporter/PLCrashReporter.h>
#import "RMCrashLogMacro.h"

#import "RMFileWriter.h"
#import "RMSystemInfo.h"
#import "RMSystemInfoNonAsyncSafe.h"
#import "RMThreadName.h"
#import "RMCrashReportFomatter.h"
#import "RMCrashNetwork.h"

#import "RMAlertView.h"
#import "RMCrashlogFolder.h"


/**
 * PLC的回调，记录一些其他的信息，比如磁盘空间，是否越狱。
 */
void recordExtraInfoCallBack(siginfo_t *info, ucontext_t *uap, void *context);

/**
 * 用来存储写其他信息的时候的文件路径。
 * 因为OC是不是async-safe，所以不能在崩溃处理时用SDK的函数生成文件路径，所以先生成。
 */
static char* extraInfoFilePath;
static char* threadNameFilePath;

@interface RMCrashLogReporter()<UIAlertViewDelegate>
@end


@implementation RMCrashLogReporter

+ (void)registerServiceWithDelegate:(id<RMCrashLogReporterConfigDataSource>)delegate;
{
    [self registerServiceWithDelegate:delegate afterDelay:1];
}


/**
 * All-in-One 初始化方法。
 * 包括：1 注册crash后的处理服务，2 检查并发送已有的crashlog
 * 这些操作不需要生成RMCrashLogRepoter的实例变量，故都是类方法。
 */

+ (void)registerServiceWithDelegate:(id<RMCrashLogReporterConfigDataSource>)delegate afterDelay:(NSTimeInterval)delay;
{
    // wait seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        RMConfig *config = delegate? [delegate crashLogReporterConfig] : [RMConfig new];
        
        /*
         *  1 Register PLC to generate crashlog
         *    and set PLC's callback for record extra info
         *    and set some other evernment that cannot be done when crash
         */
        
        // init PLC
        PLCrashReporter *plcrashReporter = [PLCrashReporter sharedReporter];
        PLCrashReporterCallbacks crashCallbacks = {
            .version = 0,
            .context = NULL,
            .handleSignal = recordExtraInfoCallBack
        };
        [plcrashReporter setCrashCallbacks:&crashCallbacks];
        NSError *error = nil;
        BOOL success = [plcrashReporter enableCrashReporterAndReturnError:&error];
        if (!success) {
            NSLog(@"[CrashReporter] could not enable PLC:%@",error.localizedDescription);
        }
        
        // init filepath for extra info
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *infoPath = [cachePath stringByAppendingPathComponent:kExtraInfoFileName];
        extraInfoFilePath = strdup([infoPath UTF8String]); // copy to heap
        NSString *threadNamePath = [cachePath stringByAppendingPathComponent:kThreadInfoFileName];
        threadNameFilePath = strdup([threadNamePath UTF8String]);

        
        
        /*
         *   2 Originize the info for last crash
         */
        
        // Init folder for store crashlogs
        NSString *crashlogFolderPath = [cachePath stringByAppendingPathComponent: kRecordedCrashFolderName];
        RMCrashlogFolder *crashlogFolder = [[RMCrashlogFolder alloc] initWithPath:crashlogFolderPath];
        RMCrashlogFolder *sendingFaildedFolder = [crashlogFolder createSubfolder:kSendingFailedLogFolderName];
        
        // Organize all crash info into RecordedCrash folder
        // including: 1 move crash log genereated by PLC
        //            2 and assemble the extra info into one dictionay, save it in the RecordedCrash folder
        //            3 name extra info dict 'extraInfo_******', where ***** is crashlog name.
        if ( [plcrashReporter hasPendingCrashReport] ) {
            NSData *protoBufData = [plcrashReporter loadPendingCrashReportDataAndReturnError:&error];
            if (protoBufData) {

                // move plc's crash
                NSString *timedName = [NSString stringWithFormat: @"%.0f", [NSDate timeIntervalSinceReferenceDate]];
                
                // assembel extra info to a dict
                
                NSMutableDictionary *infoDict = [self assembleExtraInfoAtPath:infoPath];
                NSArray *threadNames = [self assembleTheadNamesArrayAtPath:threadNamePath];
                [infoDict setObject:threadNames forKey:kThreadNamesKey];
                
                // write file
                RMCrashFile *crash = [RMCrashFile new];
                crash.logData = protoBufData;
                crash.extraInfo = infoDict;
                [crashlogFolder saveCrashFile:crash withTimedName:timedName];
                
                // clean
                [[NSFileManager defaultManager] removeItemAtPath:infoPath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:threadNamePath error:nil];
                [plcrashReporter purgePendingCrashReport];
                
            }else{
                NSLog(@"[CrashReporter] could not load PLC crash data:%@",error.localizedDescription);
            }
        }
        
        
        
        /*
         *   3 if crashed, send to server
         *     if sending is successed, delete the file.
         *     if sending fail, move to another folder, which crashes in
         *     that folder will be sent automatically.
         */
        

        void (^sendingBlock)(RMCrashlogFolder *folder, NSArray *validCrashFiles) = ^(RMCrashlogFolder *folder, NSArray *validCrashFiles){
            
            RMCrashNetwork *servant = [[RMCrashNetwork alloc] init];
            servant.config = config;
            servant.folder = folder;
            servant.crashNames = validCrashFiles;
            servant.completionBlockForEveryCrash = ^(BOOL successed, NSString *name){
                
                if (successed) {
                    // delete file
                    [folder removeCrashNamed:name];
                    NSLog(@"[crash log] sent a crash log successfully");
                }else{
                    // move to sending failed folder, it will send next time automatically
                    [folder moveCrashNamed:name toFolder:sendingFaildedFolder];
                    NSLog(@"[crash log] sending failed once");
                }
            };
            // sending
            [servant sendCrashes];  // Synchronous method run in background thread
        };
        
        // If has pending crash logs
        NSArray *validCrashFiles = [crashlogFolder crashNamesInFolder];
        BOOL hasPendingCrash = (validCrashFiles.count > 0);
        if (hasPendingCrash) {
            [self askToSend:config sendBlock:^{
                sendingBlock(crashlogFolder, validCrashFiles);
            }];
        }
        
        // automatically send crash that failed sending last time
        NSArray* sendingFailedLogNames = [sendingFaildedFolder crashNamesInFolder];
        sendingBlock( sendingFaildedFolder, sendingFailedLogNames );
        
        
        
#ifdef DEBUG
        /*
         *   4 Check after a little dalay to ensure the crash handler
         *     is not modified by others.
         *     只在debug版本中执行，为了防止其他组件（如友盟统计分析）覆盖本组件的signal的处理函数。
         *     如果signal的处理函数被更改，则本组件功能将会失效。这里只作提醒作用，如果被其他组件更改，
         *     请适量增加初始化时的延时。
         *     Crashlytics 用的是Mach—exception, 不冲突，两者可以并存。
         *
         *     TODO:这里未检查nsexceptionhander，只检查了signal
         */
        if (config.shouldCheckCrashHandlerNotModifiedByOthers) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
                // 获取signal handler
                struct sigaction sa_prev;
                sigaction(SIGABRT, NULL, &sa_prev);
                struct sigaction sa_plc;
                [plcrashReporter enableCrashReporter];
                sigaction(SIGABRT, NULL, &sa_plc);
                
                NSAssert(sa_plc.sa_sigaction == sa_prev.sa_sigaction, @"signal的处理函数被更改，请适量增加初始化时的延时");
            });
        }
#endif
    });
    
}


#pragma mark - inner methods

/*
 *  PLC的回调函数，在崩溃记录完log之后记录更多的信息
 */
void recordExtraInfoCallBack(siginfo_t *info, ucontext_t *uap, void *context)
{
    // jailbroken
    writeUnsignInt(extraInfoFilePath, "jailbreak", is_jailbroken());
    
    // disk info
    disk_info_struct_t diskInfo = get_disk_info();
    writeUnsignInt(extraInfoFilePath, "freeDisk", (unsigned)diskInfo.freeBytes);
    //    writeUnsignInt(extraInfoFilePath, "totalDisk", diskInfo->totalBytes);
    
    // ram info
    mem_info_struct_t ramInfo = get_RAM_info();
    writeUnsignInt(extraInfoFilePath,"freeRam",ramInfo.freeMem);
    writeUnsignInt(extraInfoFilePath,"usedRam",ramInfo.usedMem);
    
    // cpu usage
    writeUnsignInt(extraInfoFilePath,"cpuUsage", cpu_usage());
    
    /* get thread names */
    // get strings
    thread_name_array_t thread_names = get_thread_names();
    writeThreadNames(threadNameFilePath, thread_names);

    /*
     * 由于下面的几个信息获取的函数不是async-safe的，有潜在的可能引发问题，
     * 并且对于debug用处不大，所以暂时不用了
     */
//    // battery info
//    battery_info_struct_t batteryInfo = getBatteryLevelAndState();
//    writeUnsignInt(extraInfoFilePath, "batteryLevel", batteryInfo.batteryLevel);
//    writeUnsignInt(extraInfoFilePath, "batteryState", batteryInfo.batteryState);
//    
//    // proximity info
//    writeUnsignInt(extraInfoFilePath, "proximityState", getProximityState());
}


+ (void)askToSend:(RMConfig*)config sendBlock:(VoldBlockType)sendBlock
{
    if (!sendBlock) {
        sendBlock = ^{};
    }
    
    if ( config.shouldAutoSubmitCrashReport ||
         [[NSUserDefaults standardUserDefaults] boolForKey:kShouldAlwaysSendingCrashKey] )
    {
        // send
        sendBlock();
        
    }else{
        // show a UIAlert to let user chose
        RMAlertView *alert = [[RMAlertView alloc] initWithTitle:kAlertTitle
                                                        message:kAlertDetailContent
                                              cancelButtonTitle:@"取消"
                                               otherButtonTitle:@"发送"
                                               thirdButtonTitle:@"总是发送"
        acitonBlock:^(int index)
        {
            switch (index) {
                case RMSendingStrategyAlways:
                    // set flag
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShouldAlwaysSendingCrashKey];
                case RMSendingStrategyOnce:
                    // send
                    sendBlock();
                    break;
#if DELETE_CRASH_WHEN_PRESS_CANCEL_SENDING
                case RMSendingStrategyCancel:
                    // delete file
                    [self deleteCrashesInCrashFolder];
                    break;
#endif
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
}



#pragma mark - 整理信息到一个dictionary中

/* 
 *  通过pathWithName找到记录extraInfo的文件，并转换成一个字典
 *  @return NSDictionry, key值是记录的属性的名称, value是值
 */
+ (NSMutableDictionary *)assembleExtraInfoAtPath:(NSString*)pathWithName
{
    NSError *error = nil;
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:pathWithName encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"[CrashReporter] cound load extra info data %@",error.localizedDescription);
    }
    NSArray *allLines = [fileContent componentsSeparatedByString:@"\n"];
    
    // extra info
    NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionary];
    for (NSString* property in allLines) {
        NSArray *subStrings = [property componentsSeparatedByString:@":"];
        if(subStrings.count >= 2){
            NSString* name = [subStrings firstObject];
            NSString* value = [subStrings lastObject];
            if (name && value) {
                [infoDictionary setObject:value forKey:name];
            }
        }
    }
    return infoDictionary;
}

/*
 *  通过pathWithName找到记录线程名的文件，并转换成一个数组
 *  @return NSArray, 每个元素是线程的名字，string。
 */
+ (NSArray *)assembleTheadNamesArrayAtPath:(NSString*)pathWithName
{
    NSError *error = nil;
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:pathWithName encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"[CrashReporter] cound load thread name data. %@",error.localizedDescription);
    }
    NSArray *allLines = [fileContent componentsSeparatedByString:@"\n"];
    if (!allLines) {
        allLines = [NSArray array];
    }
    return allLines; // every line is a thead name
}


@end

@implementation RMConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        // default settings
        self.serverURL = kDefaultServerURL;
        
        self.shouldAutoSubmitCrashReport = NO;
        self.shouldCheckCrashHandlerNotModifiedByOthers = YES;
    }
    return self;
}
@end;
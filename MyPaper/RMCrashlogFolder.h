//
//  RMCrashlogFolder.h
//  MyPaper
//
//  Created by Leave on 7/17/14.
//  Copyright (c) 2014 leave. All rights reserved.
//

#import "RMFolder.h"

@interface RMCrashFile : NSObject
@property (nonatomic,strong) NSData *logData;
@property (nonatomic,strong) NSDictionary *extraInfo;
@end

@interface RMCrashlogFolder : RMFolder

- (BOOL)haveCrashlogs;
- (NSArray *)crashNamesInFolder;

- (void)saveCrashFile:(RMCrashFile *)crash withTimedName:(NSString*)name;
- (RMCrashFile *)loadCrashWithTimedName:(NSString*)name;
- (void)removeCrashNamed:(NSString *)name;

- (void)moveCrashNamed:(NSString *)file toFolder:(RMFolder *)folder;
- (RMCrashlogFolder *)createSubfolder:(NSString *)name;

@end

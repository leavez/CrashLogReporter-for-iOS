//
//  RMFolder.h
//  MyPaper
//
//  Created by Leave on 7/17/14.
//  Copyright (c) 2014 leave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMFolder : NSObject
@property (nonatomic,copy) NSString *path;


// create if not exsit
- (instancetype)initWithPath:(NSString *)path;

- (NSArray *)fileNamesInFolder;

- (void)saveDictionary:(NSDictionary *)dict withFilename:(NSString*)name;
- (void)saveData:(NSData*)data withFilename:(NSString*)name;

- (NSDictionary *)loadDictionaryWithName:(NSString*)name;
- (NSData *)loadDataWithName:(NSString*)name;

- (void)deleteFileNamed:(NSString *)name;
- (void)moveFileNamed:(NSString *)file toFolder:(RMFolder *)folder;

@end

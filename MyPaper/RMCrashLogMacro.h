//
//  RMCrashLogMacro.h
//  MyPaper
//
//  Created by leave on 14-7-7.
//  Copyright (c) 2014年 leave. All rights reserved.
//

#ifndef MyPaper_RMCrashLogMacro_h
#define MyPaper_RMCrashLogMacro_h

#ifdef DEBUG
#define DEBUG_ASSERT(condition, desc, ...) NSAssert(condition, desc, ...)
#else
#define DEBUG_ASSERT(condition, desc, ...) NSLog(desc)
#endif


#endif

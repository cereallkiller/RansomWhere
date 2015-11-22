//
//  Logging.c
//  BlockBlock
//
//  Created by Patrick Wardle on 12/21/14.
//  Copyright (c) 2015 Objective-See. All rights reserved.
//


#import "Logging.h"
#import "Consts.h"

//global log file handle
NSFileHandle* logFileHandle = nil;

//log a msg
// ->default to syslog, and if an err msg, to disk
void logMsg(int level, NSString* msg)
{
    //log prefix
    NSMutableString* logPrefix = nil;
    
    //alloc/init
    // ->always start w/ 'BLOCKBLOCK' + pid
    logPrefix = [NSMutableString stringWithFormat:@"BLOCKBLOCK(%d)", getpid()];
    
    //if its error, add error to prefix
    if(LOG_ERR == level)
    {
        //add
        [logPrefix appendString:@" ERROR"];
    }
    
    //debug mode logic
    #ifdef DEBUG
    
    //in debug mode promote debug msgs to LOG_NOTICE
    // ->OS X only shows LOG_NOTICE and above~
    if(LOG_DEBUG == level)
    {
        //promote
        level = LOG_NOTICE;
    }
    
    #endif
    
    //log to syslog
    syslog(level, "%s: %s", [logPrefix UTF8String], [msg UTF8String]);
    
    return;
}

//log to file
void log2File(NSString* msg)
{
    //sanity chec
    if(nil == logFileHandle)
    {
        //skip
        goto bail;
    }
    
    //append timestamp
    // ->write msg out
    [logFileHandle writeData:[[NSString stringWithFormat:@"%@: %@\n", [NSDate date], msg] dataUsingEncoding:NSUTF8StringEncoding]];
    
//bail
bail:
    

    return;
}

//de-init logging
void deinitLogging()
{
    //log a msg
    log2File(@"logging ending");
    
    //close file handle
    [logFileHandle closeFile];
    
    //nil out
    logFileHandle = nil;
    
    return;
}

//prep/open log file
BOOL initLogging()
{
    //ret var
    BOOL bRet = NO;
    
    //app document directory
    NSString* appDocDirectory = nil;
    
    //log file path
    NSString* logFilePath = nil;
    
    //get app's doc directory
    appDocDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    if(nil == appDocDirectory)
    {
        //err msg
        logMsg(LOG_ERR, @"failed to find application's document directory");
        
        //bail
        goto bail;
    }
    
    //build path to log file
    logFilePath = [appDocDirectory stringByAppendingPathComponent:LOG_FILE_NAME];
    
    //first time
    // ->create
    if(YES != [[NSFileManager defaultManager] fileExistsAtPath:logFilePath])
    {
        //create
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
    }
    
    //get file handle
    logFileHandle = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    if(nil == logFileHandle)
    {
        //err msg
        logMsg(LOG_ERR, [NSString stringWithFormat:@"failed to get log file handle to %@", logFilePath]);
        
        //bail
        goto bail;
    }
    
    //dbg msg
    logMsg(LOG_DEBUG, [NSString stringWithFormat:@"opened log file; %@", logFilePath]);
    
    //seek to end
    [logFileHandle seekToEndOfFile];
    
    //log a msg
    log2File(@"logging intialized");
    
    //happy
    bRet = YES;
    
//bail
bail:
    
    return bRet;
}

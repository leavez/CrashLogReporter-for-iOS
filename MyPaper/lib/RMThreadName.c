//
//  RMThreadName.m
//  RenrenMonitor
//
//  Created by zhaodg on 14-6-16.
//  Copyright (c) 2014年 renren. All rights reserved.
//

#include "RMThreadName.h"
#include <pthread.h>
#include <stdlib.h>
#include <stdbool.h>
#include <dispatch/queue.h>
#include <mach/mach.h>


bool get_thread_queue_name(const thread_t thread, char *const buffer, size_t bufLength);
bool get_thread_unix_name(const thread_t thread, char *const buffer, size_t bufLength);

thread_name_array_t get_thread_names()
{
    thread_act_array_t     threads;
    mach_msg_type_number_t thread_count;

    /* Get a list of all threads */
    if (task_threads(mach_task_self(), &threads, &thread_count) != KERN_SUCCESS) {
        //NSLog(@"Fetching thread list failed");
        thread_count = 0;
    }

    /* Suspend all but the current thread. Althought in crash dealing, the threads are alread suspend. */
    for (mach_msg_type_number_t i = 0; i < thread_count; ++i) {
        thread_t thread_self = mach_thread_self();
        mach_port_deallocate(mach_task_self(), thread_self);

        if (threads[i] != thread_self) {
            thread_suspend(threads[i]);
        }
    }

    /* get names */
    char **all_names = malloc(sizeof(char *) * thread_count);

    for (mach_msg_type_number_t i = 0; i < thread_count; ++i) {
        thread_t thread = threads[i];
        char name[128] = "";
        get_thread_unix_name(thread, name, 128);
        if (strlen(name) == 0) {
            // if no unix thread name
            if (strlen(name) > 0) {
                char thread_name_with_queue_prefix[128] = "Dispatch queue: ";
                strcat(thread_name_with_queue_prefix, name);
                all_names[i] = strdup(thread_name_with_queue_prefix);
            }else{
                all_names[i] = "";
            }
        } else {
            all_names[i] = strdup(name);
        }
    }

    thread_name_array_t return_names_array;
    return_names_array.all_names_array = all_names;
    return_names_array.count = thread_count;

    return return_names_array;
}

bool get_thread_unix_name(const thread_t thread, char *const buffer, size_t bufLength)
{
    // transfer 'thread_t' to 'pthread'
    pthread_t pt = pthread_from_mach_thread_np(thread);

    // return the error
    return pthread_getname_np(pt, buffer, bufLength);
}


bool get_thread_queue_name(const thread_t thread, char *const buffer, size_t bufLength)
{
    // WARNING: This implementation is no longer async-safe!
    
    integer_t              infoBuffer[THREAD_IDENTIFIER_INFO_COUNT] = {0};
    thread_info_t          info = infoBuffer;
    mach_msg_type_number_t inOutSize = THREAD_IDENTIFIER_INFO_COUNT;
    kern_return_t          kr = 0;
    
    kr = thread_info(thread, THREAD_IDENTIFIER_INFO, info, &inOutSize);
    
    if (kr != KERN_SUCCESS) {
        //NSLog(@"Error getting thread_info with flavor THREAD_IDENTIFIER_INFO from mach thread : %s", mach_error_string(kr));
        return false;
    }
    
    thread_identifier_info_t idInfo = (thread_identifier_info_t)info;
    dispatch_queue_t *dispatch_queue_ptr = (dispatch_queue_t *)idInfo->dispatch_qaddr; // not compitable with ARC
    
    // thread_handle shouldn't be 0 also, because identifier_info->dispatch_qaddr =  identifier_info->thread_handle + get_dispatchqueue_offset_from_proc(thread->task->bsd_info);
    if ((dispatch_queue_ptr == NULL) || (idInfo->thread_handle == 0) || (*dispatch_queue_ptr == NULL)) {
        //NSLog(@"This thread doesn't have a dispatch queue attached : %p", (void *)thread);
        return false;
    }
    
    dispatch_queue_t dispatch_queue = *dispatch_queue_ptr;
    const char       *queue_name = dispatch_queue_get_label(dispatch_queue);
    
    if (queue_name == NULL) {
        //NSLog(@"Error while getting dispatch queue name : %p", dispatch_queue);
        return false;
    }
    
    size_t length = strlen(queue_name);
    
    // Queue label must be a null terminated string.
    size_t iLabel;
    
    for (iLabel = 0; iLabel < length + 1; iLabel++) {
        if ((queue_name[iLabel] < ' ') || (queue_name[iLabel] > '~')) {
            break;
        }
    }
    
    if (queue_name[iLabel] != 0) {
        // Found a non-null, invalid char.
        //NSLog(@"Queue label contains invalid chars");
        return false;
    }
    
    bufLength = (length < bufLength - 1)? length : bufLength - 1; // just strlen, without null-terminator
    strncpy(buffer, queue_name, bufLength);
    buffer[bufLength] = 0;                  // terminate string
    return true;
}





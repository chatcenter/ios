// CCAFNetworkActivityLogger.h
//
// Copyright (c) 2015 CCAFNetworking (http://CCAFnetworking.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CCAFNetworkActivityLogger.h"
#import "CCAFURLSessionManager.h"
#import "CCAFNetworkActivityConsoleLogger.h"
#import <objc/runtime.h>

static NSError * CCAFNetworkErrorFromNotification(NSNotification *notification) {
    NSError *error = nil;
    if ([[notification object] isKindOfClass:[NSURLSessionTask class]]) {
        error = [(NSURLSessionTask *)[notification object] error];
        if (!error) {
            error = notification.userInfo[CCAFNetworkingTaskDidCompleteErrorKey];
        }
    }
    return error;
}

@interface CCAFNetworkActivityLogger ()
@property (nonatomic, strong) NSMutableSet *mutableLoggers;

@end

@implementation CCAFNetworkActivityLogger

+ (instancetype)sharedLogger {
    static CCAFNetworkActivityLogger *_sharedLogger = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [[self alloc] init];
    });

    return _sharedLogger;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.mutableLoggers = [NSMutableSet set];

    CCAFNetworkActivityConsoleLogger *consoleLogger = [CCAFNetworkActivityConsoleLogger new];
    [self addLogger:consoleLogger];

    return self;
}

- (NSSet *)loggers {
    return self.mutableLoggers;
}

- (void)dealloc {
    [self stopLogging];
}

- (void)addLogger:(id<CCAFNetworkActivityLoggerProtocol>)logger {
    [self.mutableLoggers addObject:logger];
}

- (void)removeLogger:(id<CCAFNetworkActivityLoggerProtocol>)logger {
    [self.mutableLoggers removeObject:logger];
}

- (void)startLogging {
    [self stopLogging];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidStart:) name:CCAFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkRequestDidFinish:) name:CCAFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)stopLogging {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotification

static void * CCAFNetworkRequestStartDate = &CCAFNetworkRequestStartDate;

- (void)networkRequestDidStart:(NSNotification *)notification {
    NSURLSessionTask *task = [notification object];
    NSURLRequest *request = task.originalRequest;

    if (!request) {
        return;
    }

    objc_setAssociatedObject(notification.object, CCAFNetworkRequestStartDate, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    for (id <CCAFNetworkActivityLoggerProtocol> logger in self.loggers) {
        if (request && logger.filterPredicate && [logger.filterPredicate evaluateWithObject:request]) {
            return;
        }

        [logger URLSessionTaskDidStart:task];
    }
}

- (void)networkRequestDidFinish:(NSNotification *)notification {
    NSURLSessionTask *task = [notification object];
    NSURLRequest *request = task.originalRequest;
    NSURLResponse *response = task.response;
    NSError *error = CCAFNetworkErrorFromNotification(notification);

    if (!request && !response) {
        return;
    }

    id responseObject = nil;
    if (notification.userInfo) {
        responseObject = notification.userInfo[CCAFNetworkingTaskDidCompleteSerializedResponseKey];
    }

    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:objc_getAssociatedObject(notification.object, CCAFNetworkRequestStartDate)];

    for (id <CCAFNetworkActivityLoggerProtocol> logger in self.loggers) {
        if (request && logger.filterPredicate && [logger.filterPredicate evaluateWithObject:request]) {
            return;
        }

        [logger URLSessionTaskDidFinish:task withResponseObject:responseObject inElapsedTime:elapsedTime withError:error];
    }
}

@end

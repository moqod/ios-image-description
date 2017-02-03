//
//  MAImageLoader.m
//  ImageDescription
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import "MAImageProducer.h"
#import "MAImageDescriptionLoadingOperation.h"

@interface MAImageProducer () <MAImageDescriptionLoadingOperationDelegate>

@property (nonatomic, strong) NSMutableDictionary       *queuesDictionary;

@end

@implementation MAImageProducer

+ (instancetype)defaultProducer {
    static dispatch_once_t predicate;
    static id sharedInstance = nil;
    dispatch_once(&predicate, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.queuesDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - queue stuff

- (NSOperationQueue *)operationQueueForKey:(NSString *)key maxConcurrentOperations:(NSInteger)maxConcurrentOperations {
    NSOperationQueue *queue = self.queuesDictionary[key];
    if (!queue) {
        queue = [NSOperationQueue new];
        queue.maxConcurrentOperationCount = maxConcurrentOperations;
        self.queuesDictionary[key] = queue;
    }
    return queue;
}

- (NSOperationQueue *)originalSourceOperationQueueWithAlias:(NSString *)alias {
    alias = alias ?: @"default";
    return [self operationQueueForKey:alias maxConcurrentOperations:1];
}

- (NSOperationQueue *)cacheOperationQueueWithAlias:(NSString *)alias {
    alias = alias ?: @"default";
    alias = [alias stringByAppendingString:@".cache"];
    return [self operationQueueForKey:alias maxConcurrentOperations:2];
}

#pragma mark -

- (void)produceImageWithDescription:(MAImageDescription *)imageDescription {
    if (imageDescription) {
        
        NSOperationQueue *relevantQueue = [self originalSourceOperationQueueWithAlias:imageDescription.loadingQueueAlias];
        MAImageDescriptionLoadingOperation *operation = [MAImageDescriptionLoadingOperation operationWithDescription:imageDescription];
        operation.delegate = self;
        [relevantQueue addOperation:operation];
    }
}

- (void)cancelProducingImageWithDescription:(MAImageDescription *)imageDescription {
    NSOperationQueue *relevantQueue = [self originalSourceOperationQueueWithAlias:imageDescription.loadingQueueAlias];
    for (MAImageDescriptionLoadingOperation *operation in relevantQueue.operations) {
        // user could swipe images left - right, easy implementation
        if ([operation.imageDescription isEqual:imageDescription] && !operation.isCancelled) {
            [operation cancel];
            break;
        }
    }
}

#pragma mark - MAImageDescriptionLoadingOperationDelegate

- (void)loadingOperation:(MAImageDescriptionLoadingOperation *)operation didFailWithError:(NSError *)error forImageDescription:(MAImageDescription *)imageDescription {
    // send notification
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:error forKey:@"error"];
    [[NSNotificationCenter defaultCenter] postNotificationName:imageDescription.imageFilePath object:self userInfo:userInfo];
}

- (void)loadingOperation:(MAImageDescriptionLoadingOperation *)operation didLoadImage:(UIImage *)image forImageDescription:(MAImageDescription *)imageDescription {
    // send notification
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:image forKey:@"result"];
    [[NSNotificationCenter defaultCenter] postNotificationName:imageDescription.imageFilePath object:self userInfo:userInfo];
}

@end

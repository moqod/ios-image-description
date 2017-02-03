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

@property (nonatomic, readonly) NSOperationQueue        *fastOperationQueue;
@property (nonatomic, readonly) NSOperationQueue        *slowOperationQueue;

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
        _fastOperationQueue = [NSOperationQueue new];
        self.fastOperationQueue.maxConcurrentOperationCount = 1;
        
        _slowOperationQueue = [NSOperationQueue new];
        self.slowOperationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark -

- (void)produceImageWithDescription:(MAImageDescription *)imageDescription {
    if (imageDescription) {
        BOOL relativelyFast = NO;
        
        NSOperationQueue *relevantQueue = relativelyFast ? self.fastOperationQueue : self.slowOperationQueue;
        MAImageDescriptionLoadingOperation *operation = [MAImageDescriptionLoadingOperation operationWithDescription:imageDescription];
        operation.delegate = self;
        [relevantQueue addOperation:operation];
    }
}

- (void)cancelProducingImageWithDescription:(MAImageDescription *)imageDescription {
    BOOL relativelyFast = NO;
    NSOperationQueue *relevantQueue = relativelyFast ? self.fastOperationQueue : self.slowOperationQueue;

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

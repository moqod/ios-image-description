//
//  MAImageLoader.m
//  ImageDescription
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import "MAImageProducer.h"
#import "MAImageDescriptionOperation.h"

@interface MAImageProducer ()

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
        BOOL relativelyFast = [imageDescription.sourceModel respondsToSelector:@selector(isRelativelyFast)] ? [imageDescription.sourceModel isRelativelyFast] : YES;
        if ([imageDescription cacheExists]) {
            relativelyFast = YES;
        }
        
        NSOperationQueue *relevantQueue = relativelyFast ? self.fastOperationQueue : self.slowOperationQueue;
        [relevantQueue addOperation:[MAImageDescriptionOperation operationWithDescription:imageDescription]];
    }
}

- (void)cancelProducingImageWithDescription:(MAImageDescription *)imageDescription {
    BOOL relativelyFast = [imageDescription.sourceModel respondsToSelector:@selector(isRelativelyFast)] ? [imageDescription.sourceModel isRelativelyFast] : YES;
    NSOperationQueue *relevantQueue = relativelyFast ? self.fastOperationQueue : self.slowOperationQueue;

    for (MAImageDescriptionOperation *operation in relevantQueue.operations) {
        // user could swipe images left - right, easy implementation
        if ([operation.imageDescription isEqual:imageDescription] && !operation.isCancelled) {
            [operation cancel];
            break;
        }
    }
}

@end

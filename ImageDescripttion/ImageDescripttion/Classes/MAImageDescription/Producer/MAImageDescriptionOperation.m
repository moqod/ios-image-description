//
//  MAImageDescriptionOperation.m
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAImageDescriptionOperation.h"

@interface MAImageDescriptionOperation ()

@property (atomic, readwrite) BOOL isExecuting;
@property (atomic, readwrite) BOOL isFinished;

@property (nonatomic, strong) MAImageDescription     *imageDescription;

@end

@implementation MAImageDescriptionOperation

+ (instancetype)operationWithDescription:(MAImageDescription *)imageDescription {
    MAImageDescriptionOperation *operation = [self new];
    operation.imageDescription = imageDescription;
    return operation;
}

#pragma mark -

- (void)start {
    [super start];

    if (!self.isCancelled) {
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];

        [self.imageDescription imageWithCompletion:^(UIImage *image, NSError *error) {
            [self markOperationCompleted];
        }];
    } else {
        [self markOperationCompleted];
    }
}

#pragma mark - NSOperation stuff

- (void)markOperationCompleted {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isReady {
    return YES;
}

@end

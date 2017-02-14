//
//  MAImageDescriptionOperation.m
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAImageDescriptionLoadingOperation.h"
#import "MAImageHelper.h"

@interface MAImageDescriptionLoadingOperation ()

@property (atomic, readwrite) BOOL isExecuting;
@property (atomic, readwrite) BOOL isFinished;

@property (nonatomic, strong) MAImageDescription     *imageDescription;

@end

@implementation MAImageDescriptionLoadingOperation

+ (instancetype)operationWithDescription:(MAImageDescription *)imageDescription {
    MAImageDescriptionLoadingOperation *operation = [self new];
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
        
        NSString *resultFilePath = self.imageDescription.imageFilePath;
        UIImage *cachedImage = [UIImage imageWithContentsOfFile:resultFilePath];
        if (cachedImage != nil) {
            // draw offscreen
            cachedImage = [MAImageHelper offscreenDrawnImage:cachedImage];
            [self notifyDelegateDidLoadImage:cachedImage fromCache:YES error:nil];
            [self markOperationCompleted];
        } else {
            __weak typeof (self) welf = self;
            [self.imageDescription.sourceModel imageWithCompletion:^(UIImage *image, NSError *error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (!self.isCancelled) {
                        if (!error) {
                            UIImage *decoratedImage = image;
                            for (id <MAImageTransformation> decorator in welf.imageDescription.transformations) {
                                decoratedImage = [decorator applyTransformationToImage:decoratedImage];
                            }
                            
                            // save decorated image
                            [welf cacheResultImage:decoratedImage];
                            
                            // draw offscreen
                            decoratedImage = [MAImageHelper offscreenDrawnImage:decoratedImage];
                            
                            [welf notifyDelegateDidLoadImage:decoratedImage fromCache:NO error:nil];
                            [welf markOperationCompleted];
                        } else {
                            [welf notifyDelegateDidLoadImage:nil fromCache:NO error:error];
                            [welf markOperationCompleted];
                        }
                    } else {
                        [welf cancelOperation];
                    }
                });
            }];
        }
    } else {
        [self cancelOperation];
    }
}

#pragma mark - cache

- (void)cacheResultImage:(UIImage *)image {
    @autoreleasepool {
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:self.imageDescription.imageFilePath atomically:YES];
    }
}

#pragma mark - helpers

- (void)cancelOperation {
    NSError *error = [NSError errorWithDomain:MAImageDescriptionErrorDomain code:MASourceErrorCancelled userInfo:nil];
    [self notifyDelegateDidLoadImage:nil fromCache:NO error:error];
    [self markOperationCompleted];
}

- (void)notifyDelegateDidLoadImage:(UIImage *)image fromCache:(BOOL)fromCache error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (image) {
            if ([self.delegate respondsToSelector:@selector(loadingOperation:didLoadImage:forImageDescription:fromCache:)]) {
                [self.delegate loadingOperation:self didLoadImage:image forImageDescription:self.imageDescription fromCache:fromCache];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(loadingOperation:didFailWithError:forImageDescription:)]) {
                [self.delegate loadingOperation:self didFailWithError:error forImageDescription:self.imageDescription];
            }
        }
    });
}

- (void)markOperationCompleted {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - NSOperation

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isReady {
    return YES;
}

/*
- (void)imageWithCompletion:(void (^)(UIImage *image, NSError *error))completion {
    if (!self.sourceModel) {
        [self callCompletionWithImage:nil error:nil fromCache:NO completion:completion];
    } else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.imageFilePath]) {
            // seems like we already cache & did this image
            MAFileImageSourceModel *fileSourceModel = [[MAFileImageSourceModel alloc] initWithFilePath:self.imageFilePath];
            [fileSourceModel imageWithCompletion:^(UIImage *image, NSError *error) {
                [self callCompletionWithImage:image error:error fromCache:YES completion:completion];
            }];
        } else {
            [self.sourceModel imageWithCompletion:^(UIImage *image, NSError *error) {
                if (self.transformations.count) {
                    if (!error) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIImage *decoratedImage = image;
                            for (id <MAImageTransformation> decorator in self.transformations) {
                                decoratedImage = [decorator applyTransformationToImage:decoratedImage];
                            }
                            
                            // save decorated image
                            NSData *data = UIImagePNGRepresentation(decoratedImage);
                            [data writeToFile:self.imageFilePath atomically:YES];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self callCompletionWithImage:decoratedImage error:nil fromCache:NO completion:completion];
                            });
                        });
                    } else {
                        [self callCompletionWithImage:nil error:error fromCache:NO completion:completion];
                    }
                } else {
                    [self callCompletionWithImage:image error:error fromCache:NO completion:completion];
                }
            }];
        }
    }
}*/

@end

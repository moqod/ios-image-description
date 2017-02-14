//
//  MAURLImageSourceModel.m
//  ImageDescription
//
//  Created by Andrew Kopanev on 3/7/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAURLImageSourceModel.h"
#import "MAImageHelper.h"
#import "MAErrors.h"

@interface MAURLImageSourceModel () <NSURLSessionDelegate>

@property (nonatomic, copy) void (^completion)(UIImage *, NSError *);

@end

@implementation MAURLImageSourceModel

#pragma mark - inititalization

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

+ (instancetype)sourceWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

#pragma mark - helpers

- (NSString *)filenameFromURL:(NSURL *)url {
    // NAME_MAX == 255
    const NSInteger maxLength = 128;
    NSString *name = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    if (name.length > maxLength) {
        name = [name substringFromIndex:name.length - maxLength];
    }
    return name;
}

- (NSString *)cachedImageFilePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[self sourceName]];
}

#pragma mark - MAImageSource

- (NSString *)sourceName {
    return [NSString stringWithFormat:@"url_%@", [self filenameFromURL:self.url]];
}

// block to return UIImage
- (void)imageWithCompletion:(void (^)(UIImage *image, NSError *error))completion {
    self.completion = completion;
    
    // TODO: support `file://` protocol
    // the app crashes because of this now, workaround implemented
    BOOL workaroundIsFile = [self.url isFileURL];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachedImageFilePath]] || workaroundIsFile) {
        [self loadImageAndCallCompletion];
    } else {
        if (!self.url) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:MAImageDescriptionErrorDomain code:MASourceErrorBadURL userInfo:nil];
                [self callCompletionWithImage:nil error:error completion:completion];
            });
        } else {
            NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
            NSURLSessionDownloadTask *task = [session downloadTaskWithURL:self.url
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            
                                                            if (error != nil) {
                                                                NSLog(@"url == %@", self.url);
                                                                NSLog(@"! path == %@", [self cachedImageFilePath]);;
                                                                NSLog(@"error == %@", error);
                                                            }
                                                            
                                                            
                                                            if (!error) {
                                                                if ([[NSFileManager defaultManager] fileExistsAtPath:[self cachedImageFilePath]]) {
                                                                    [[NSFileManager defaultManager] removeItemAtPath:[self cachedImageFilePath] error:nil];
                                                                }
                                                                [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:[self cachedImageFilePath] error:nil];
                                                                [self loadImageAndCallCompletion];
                                                            } else {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [self callCompletionWithImage:nil error:error completion:self.completion];
                                                                    //    self.completion = nil;
                                                                });
                                                            }
                                                        }];
            
            [task resume];
        }
    }
}

#pragma mark - helpers

- (void)loadImageAndCallCompletion {
    // TODO: support `file://` protocol
    // the app crashes because of this now, workaround implemented
    BOOL workaroundIsFile = [self.url isFileURL];

    NSString *imageFilePath = [self cachedImageFilePath];
    if (workaroundIsFile) {
        imageFilePath = self.url.path;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
    NSError *error = nil;
    if (!image) {
        [[NSFileManager defaultManager] removeItemAtPath:[self cachedImageFilePath] error:nil];
        error = [NSError errorWithDomain:MAImageDescriptionErrorDomain code:MASourceErrorFileIsNotAnImage userInfo:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callCompletionWithImage:image error:error completion:self.completion];
        //    self.completion = nil;
    });
}

- (void)callCompletionWithImage:(UIImage *)image error:(NSError *)error completion:(void (^)(UIImage *image, NSError *error))completion {
    if (completion) {
        completion(image, error);
    }
}

#pragma mark - equatability

- (BOOL)isEqualToImageSource:(MAURLImageSourceModel *)model {
    if ([model isKindOfClass:self.class]) {
        return [model.url.absoluteString isEqualToString:self.url.absoluteString];
    } else {
        return NO;
    }
}

@end

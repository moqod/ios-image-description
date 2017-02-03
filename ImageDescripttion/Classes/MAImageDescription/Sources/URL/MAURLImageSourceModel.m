//
//  MAURLImageSourceModel.m
//  ImageDescription
//
//  Created by Andrew Kopanev on 3/7/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAURLImageSourceModel.h"
#import "MAImageHelper.h"

static NSString *MAURLImageSourceModelDestinationFolderPath = nil;

@interface MAURLImageSourceModel () <NSURLSessionDelegate>

@property (nonatomic, copy) void (^completion)(UIImage *, NSError *);

@end

@implementation MAURLImageSourceModel

+ (void)initialize {
    if (!MAURLImageSourceModelDestinationFolderPath) {
        MAURLImageSourceModelDestinationFolderPath = NSTemporaryDirectory();
    }
}

+ (void)setDestinationDirectoryPath:(NSString *)destinationDirectoryPath {
    if (destinationDirectoryPath) {
        MAURLImageSourceModelDestinationFolderPath = destinationDirectoryPath;
    }
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        
        // file paths
        self.destinationDirectoryPath = MAURLImageSourceModelDestinationFolderPath;
        self.imageFileName = [self.url lastPathComponent];
    }
    return self;
}

- (NSString *)resultImageName {
    return self.imageFileName;
}

- (NSString *)cachedImageFilePath {
    return [self.destinationDirectoryPath stringByAppendingPathComponent:self.resultImageName];
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
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:self.url
                                                    completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
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

#pragma mark -

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
        error = [NSError errorWithDomain:MAImageSourceErrorDomain code:MAImageSourceErrorFileIsNotAnImage userInfo:nil];
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


- (BOOL)isEqualToImageSource:(id<MAImageSource>)model {
    if ([model isKindOfClass:self.class]) {
        MAURLImageSourceModel *urlModel = (id)model;
        return [urlModel.url.absoluteString isEqualToString:self.url.absoluteString];
    }
    return NO;
}

@end

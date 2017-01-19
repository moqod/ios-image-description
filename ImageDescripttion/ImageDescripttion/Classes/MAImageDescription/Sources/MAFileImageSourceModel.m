//
//  MAFilePathImageSourceModel.m
//
//  Created by Andrew Kopanev on 3/1/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAFileImageSourceModel.h"
#import "MAImageHelper.h"

@implementation MAFileImageSourceModel

- (NSString *)resultImageName {
    return [self.filePath lastPathComponent];
}

#pragma mark - initialization

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.filePath = filePath;
    }
    return self;
}
- (instancetype)initWithFilePath:(NSString *)filePath andConfigBlock:(MAFileImageSourceModelConfigBlock_t)block {
    self = [self initWithFilePath:filePath];
    if (self) {
        self.configBlock = block;
    }
    return self;
}

+ (instancetype)sourceWithImageNamed:(NSString *)imageName {
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *filePath = [bundlePath stringByAppendingPathComponent:imageName];
    return [[self alloc] initWithFilePath:filePath];
}

+ (instancetype)sourceWithImagePath:(NSString *)imagePath {
    return [[self alloc] initWithFilePath:imagePath];
}

#pragma mark - private

- (NSString *)appropriateImageFilePath:(NSString *)filePath {
    NSString *fileName = [filePath lastPathComponent];
    NSString *extension = [fileName pathExtension];
    
    // get file name without extension
    NSString *modifiedFileName = fileName;
    if (extension.length > 0) {
        modifiedFileName = [fileName stringByDeletingPathExtension];
    }
    
    // update file name
    NSString *scaleValue = [NSString stringWithFormat:@"%.0fx", [UIScreen mainScreen].scale];
    NSMutableArray *components = [modifiedFileName componentsSeparatedByString:@"@"].mutableCopy;
    if (components.count > 1) {
        // update existing scale value
        [components removeLastObject];
    }
    [components addObject:scaleValue];
    modifiedFileName = [components componentsJoinedByString:@"@"];
    
    if (extension.length) {
        modifiedFileName = [modifiedFileName stringByAppendingPathExtension:extension];
    }
    
    NSString *updatedFileName = [filePath stringByReplacingOccurrencesOfString:fileName withString:modifiedFileName options:0 range:NSMakeRange(filePath.length - fileName.length, fileName.length)];
    
    return updatedFileName;
}

#pragma mark - public

- (BOOL)isRelativelyFast {
    return YES;
}

- (void)imageWithCompletion:(MAImageCompletionBlock_t)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // try to load at provided file path
        NSString *actualFilePath = self.filePath;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:actualFilePath];
        if (!fileExists) {
            actualFilePath = [self appropriateImageFilePath:self.filePath];
            fileExists = [[NSFileManager defaultManager] fileExistsAtPath:actualFilePath];
        }
        
        if (!fileExists) {
            NSLog(@"%s image does not exist at path == %@", __PRETTY_FUNCTION__, actualFilePath);
            
            [self callCompletionOnMainThreadWithImage:nil error:[NSError errorWithDomain:MAImageSourceErrorDomain code:MAImageSourceErrorFileDoesNotExist userInfo:nil] completion:completion];
        } else {
            BOOL configured = NO;
            UIImage *image = nil;
            if (self.configBlock) {
                image = self.configBlock(actualFilePath);
                configured = image != nil;
            }
            if (!image) {
                image = [[UIImage alloc] initWithContentsOfFile:actualFilePath];
            }
            if (!image) {
                [self callCompletionOnMainThreadWithImage:nil error:[NSError errorWithDomain:MAImageSourceErrorDomain code:MAImageSourceErrorFileIsNotAnImage userInfo:nil] completion:completion];
            } else {
                if (!configured) {
                    // offscreen decoding & drawing
                    image = [MAImageHelper offscreenDrawnImage:image];
                }
                [self callCompletionOnMainThreadWithImage:image error:nil completion:completion];
            }
        }
    });
}

- (void)callCompletionOnMainThreadWithImage:(UIImage *)image error:(NSError *)error completion:(MAImageCompletionBlock_t)completion {
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image, error);
        });
    }
}


- (BOOL)isEqualToImageSource:(id<MAImageSource>)model {
    if ([model isKindOfClass:self.class]) {
        MAFileImageSourceModel *urlModel = (id)model;
        return [urlModel.filePath isEqualToString:self.filePath];
    }
    return NO;
}

@end

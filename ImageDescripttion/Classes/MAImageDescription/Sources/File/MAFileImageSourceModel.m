//
//  MAFilePathImageSourceModel.m
//
//  Created by Andrew Kopanev on 3/1/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAFileImageSourceModel.h"
#import "MAImageHelper.h"

#import "MAErrors.h"

@interface MAFileImageSourceModel ()

@property (nonatomic, strong) NSString                 *filePath;

@end

@implementation MAFileImageSourceModel

#pragma mark - initialization

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.filePath = filePath;
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

#pragma mark - MAImageSource

- (NSString *)sourceName {
    return [self.filePath lastPathComponent];
}

- (void)imageWithCompletion:(void (^)(UIImage *image, NSError *error))completion {
    // try to load at provided file path
    NSString *actualFilePath = self.filePath;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:actualFilePath];
    if (!fileExists) {
        actualFilePath = [self appropriateImageFilePath:self.filePath];
        fileExists = [[NSFileManager defaultManager] fileExistsAtPath:actualFilePath];
    }
    
    if (!fileExists) {
        NSLog(@"%s image does not exist at path == %@", __PRETTY_FUNCTION__, actualFilePath);
        [self callCompletionOnMainThreadWithImage:nil
                                            error:[NSError errorWithDomain:MAImageDescriptionErrorDomain code:MASourceErrorFileDoesNotExist userInfo:nil]
                                       completion:completion];
    } else {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:actualFilePath];
        if (!image) {
            [self callCompletionOnMainThreadWithImage:nil
                                                error:[NSError errorWithDomain:MAImageDescriptionErrorDomain code:MASourceErrorFileIsNotAnImage userInfo:nil]
                                           completion:completion];
        } else {
            [self callCompletionOnMainThreadWithImage:image error:nil completion:completion];
        }
    }
}

- (void)callCompletionOnMainThreadWithImage:(UIImage *)image error:(NSError *)error completion:(void (^)(UIImage *image, NSError *error))completion {
    if (completion) {
        completion(image, error);
    }
}

#pragma mark - helpers

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

@end

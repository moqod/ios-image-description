//
//  MAImageDescription.m
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAImageDescription.h"

#import "MAFileImageSourceModel.h"
#import "MAResizeImageDecorator.h"

// constants
NSString *const MAImageSourceErrorDomain            = @"MAImageSourceErrorDomain";

@implementation MAImageDescription

#pragma mark - initialization

- (instancetype)initWithSourceModel:(id <MAImageSource>)sourceModel decorators:(NSArray *)decorators {
    self = [super init];
    if (self) {
        self.decorators = (id)decorators; //(id) - make compiler happy :)
        self.sourceModel = sourceModel;
    }
    return self;
}

+ (instancetype)descriptionWithImageNamed:(NSString *)fileName {
    return [[self alloc] initWithSourceModel:[MAFileImageSourceModel sourceWithImageNamed:fileName] decorators:nil];
}

#pragma mark - image name

- (NSString *)resultImageName {
    NSMutableString *imageName = [NSMutableString stringWithString:self.sourceModel.resultImageName ?: @""];
    for (id <MAImageDecorator> decorator in self.decorators) {
        [imageName appendFormat:@"%@%@", imageName.length ? @"_" : @"", decorator.transformName];
    }
    return imageName;
}

- (NSString *)resultImageFilePath {
    // TODO: please use some directory for images
    NSString *directoryPath = NSTemporaryDirectory();
    return [directoryPath stringByAppendingString:self.resultImageName];
}

#pragma mark -

- (NSUInteger)hash {
    return [self.resultImageName hash];
}

- (BOOL)isEqual:(MAImageDescription *)object {
    return [object isKindOfClass:[self class]] && [self.resultImageName isEqualToString:object.resultImageName];
}


#pragma mark - producing an image

- (BOOL)cacheExists {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self resultImageFilePath]];
}

- (void)imageWithCompletion:(MAImageCompletionBlock_t)completion {
    if (!self.sourceModel) {
        [self callCompletionWithImage:nil error:nil fromCache:NO completion:completion];
    } else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self resultImageFilePath]]) {
            // seems like we already cache & did this image
            MAFileImageSourceModel *fileSourceModel = [[MAFileImageSourceModel alloc] initWithFilePath:[self resultImageFilePath]];
            [fileSourceModel imageWithCompletion:^(UIImage *image, NSError *error) {
                [self callCompletionWithImage:image error:error fromCache:YES completion:completion];
            }];
        } else {
            [self.sourceModel imageWithCompletion:^(UIImage *image, NSError *error) {
                if (self.decorators.count) {
                    if (!error) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            UIImage *decoratedImage = image;
                            for (id <MAImageDecorator> decorator in self.decorators) {
                                decoratedImage = [decorator decoratedImage:decoratedImage];
                            }
                            
                            // save decorated image
                            NSData *data = UIImagePNGRepresentation(decoratedImage);
                            [data writeToFile:[self resultImageFilePath] atomically:YES];
                            
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
}

- (void)callCompletionWithImage:(UIImage *)image error:(NSError *)error fromCache:(BOOL)fromCache completion:(MAImageCompletionBlock_t)completion {
    if (completion) {
        completion(image, error);
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:image forKey:@"result"];
    [userInfo setValue:error forKey:@"error"];
    [userInfo setValue:@(fromCache) forKey:@"cache"];
    [[NSNotificationCenter defaultCenter] postNotificationName:self.resultImageName object:self userInfo:userInfo];
}

@end

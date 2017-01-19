//
//  MAAssetImageSourceModel.m
//  AirCam
//
//  Created by Andrew Kopanev on 3/7/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAAssetImageSourceModel.h"

@interface MAAssetImageSourceModel ()

@property (nonatomic, copy) MAImageCompletionBlock_t completion;

@end

@implementation MAAssetImageSourceModel

- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize {
    if (self = [super init]) {
        _photoAsset = asset;
        _targetSize = targetSize;
        _contentMode = PHImageContentModeAspectFit;
    }
    return self;
}

- (NSString *)resultImageName {
    return [NSString stringWithFormat:@"%@_%.2fx%.2f_%@", self.photoAsset.localIdentifier, self.targetSize.width, self.targetSize.height, @( self.contentMode )];
}

- (BOOL)isRelativelyFast {
    return YES;
}

- (void)imageWithCompletion:(void (^)(UIImage *, NSError *))completion {
    self.completion = completion;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.version = PHImageRequestOptionsVersionOriginal;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize realSize = CGSizeMake(self.targetSize.width * scale, self.targetSize.height * scale);
    
    [[PHImageManager defaultManager] requestImageForAsset:self.photoAsset
                                               targetSize:realSize
                                              contentMode:self.contentMode
                                                  options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                      // skip low-quality
                                                      if (![info[PHImageResultIsDegradedKey] boolValue]) {
                                                          [self callCompletionWithImage:result error:info[PHImageErrorKey] completion:self.completion];
                                                      }
                                                  }];
}

- (void)callCompletionWithImage:(UIImage *)image error:(NSError *)error completion:(MAImageCompletionBlock_t)completion {
    if (completion) {
        if ([NSThread isMainThread]) {
            completion(image, error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image, error);
            });
        }
    }
}

- (BOOL) isEqualToImageSource:(id<MAImageSource>)model {
    return false;
}

@end

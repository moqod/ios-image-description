//
//  MAResizeImageTransformation.m
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/3/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import "MAResizeImageTransformation.h"
#import "MAImageHelper.h"

@implementation MAResizeImageTransformation

#pragma mark - initialization

- (instancetype)init {
    if (self = [super init]) {
        self.size = CGSizeZero;
        self.resizeType = MAResizeAspectFill;
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size resizeType:(MAResizeType)resizeType {
    if (self = [self init]) {
        self.size = size;
        self.resizeType = resizeType;
    }
    return self;
}

+ (instancetype)transformationWithSize:(CGSize)size {
    return [[self alloc] initWithSize:size resizeType:MAResizeAspectFill];
}

#pragma mark - helpers

- (NSString *)resizeTypeName:(MAResizeType)resizeType {
    return resizeType == MAResizeAspectFill ? @"fill" : @"fit";
}

#pragma mark - MAImageTransformation

- (NSString *)transformationName {
    return [NSString stringWithFormat:@"%@%.0fx%.0f", [self resizeTypeName:self.resizeType], self.size.width, self.size.height];
}

- (UIImage *)applyTransformation:(UIImage *)image {
    if (self.size.width > 0.0 && self.size.height > 0.0) {
        UIImage *decoratedImage = nil;
        if (self.resizeType == MAResizeAspectFill) {
            decoratedImage = [MAImageHelper imageCroppedToFitSize:self.size image:image];
        } else {
            decoratedImage = [MAImageHelper imageScaledToFitSize:self.size image:image];
        }
        return decoratedImage;
    } else {
        NSLog(@"%s did nothing, size is empty!", __PRETTY_FUNCTION__);
        return image;
    }
}

@end

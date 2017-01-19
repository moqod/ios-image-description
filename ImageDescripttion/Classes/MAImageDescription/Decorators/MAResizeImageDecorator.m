//
//  MAResizeImageDecorator.m
//  MAImageCrop
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import "MAResizeImageDecorator.h"
#import "MAImageHelper.h"

@implementation MAResizeImageDecorator

#pragma mark - initialization

- (instancetype)init {
    if (self = [super init]) {
        self.size = CGSizeZero;
        self.resizeType = MAResizeAspectFill;
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size {
    self = [self init];
    if (self) {
        self.size = size;
    }
    return self;
}

#pragma mark -

- (NSString *)transformName {
    return [NSString stringWithFormat:@"%@%.0fx%.0f", self.resizeType == MAResizeAspectFill ? @"fill" : @"fit", self.size.width, self.size.height];
}

- (UIImage *)decoratedImage:(UIImage *)image {
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

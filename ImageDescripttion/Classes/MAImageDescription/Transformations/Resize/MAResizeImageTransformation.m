//
//  MAResizeImageTransformation.m
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/3/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import "MAResizeImageTransformation.h"
#import "MAImageHelper.h"

NSString *NSStringFromMAResizeType(MAResizeType resizeType) {
    switch (resizeType) {
        case MAResizeAspectFill:
            return @"fill";
        case MAResizeAspectFit:
            return @"fit";
    }
}

@implementation MAResizeImageTransformation

#pragma mark - initialization

- (instancetype)init {
    return [self initWithSize:CGSizeZero resizeType:MAResizeAspectFill];
}

- (instancetype)initWithSize:(CGSize)size resizeType:(MAResizeType)resizeType {
    if (self = [super init]) {
        _size = size;
        _resizeType = resizeType;
    }
    return self;
}

+ (instancetype)transformationWithSize:(CGSize)size {
    return [[self alloc] initWithSize:size resizeType:MAResizeAspectFill];
}

#pragma mark - MAImageTransformation

- (NSString *)transformationName {
    return [NSString stringWithFormat:@"%@%.0fx%.0f", NSStringFromMAResizeType(self.resizeType), self.size.width, self.size.height];
}

- (UIImage *)transformedImageWithImage:(UIImage *)image {
    if (CGSizeEqualToSize(self.size, CGSizeZero)) {
        NSLog(@"%s did nothing, size is empty!", __PRETTY_FUNCTION__);
        return image;
    }
    
    switch (self.resizeType) {
        case MAResizeAspectFill:
            return [MAImageHelper imageCroppedToFitSize:self.size image:image];
        case MAResizeAspectFit:
            return [MAImageHelper imageScaledToFitSize:self.size image:image];
    }
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@>", [super description], self.transformationName];
}

@end

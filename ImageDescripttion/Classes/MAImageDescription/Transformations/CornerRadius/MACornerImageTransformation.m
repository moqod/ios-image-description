//
//  MACornerImageTransformation.m
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/3/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import "MACornerImageTransformation.h"

NSString *NSStringFromUIRectCorner(UIRectCorner corners) {
    NSMutableString *string = [NSMutableString string];
    NSDictionary *mapping = @{
                              @(UIRectCornerBottomLeft) : @"bl",
                              @(UIRectCornerBottomRight) : @"br",
                              @(UIRectCornerTopLeft) : @"tl",
                              @(UIRectCornerTopRight) : @"tr"
                              };
    
    for (NSNumber *number in mapping.allKeys) {
        if (corners & number.integerValue) {
            [string appendString:mapping[number]];
        }
    }
    return string;
}

@implementation MACornerImageTransformation

#pragma mark - initialization

- (instancetype)initWithCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    if (self = [super init]) {
        _corners = corners;
        _radius = radius;
    }
    return self;
}

+ (instancetype)transformationWithRadius:(CGFloat)radius {
    return [[self alloc] initWithCorners:UIRectCornerAllCorners radius:radius];
}

#pragma mark - MAImageTransformation

- (NSString *)transformationName {
    return [NSString stringWithFormat:@"corner_%.0f_%@", self.radius, NSStringFromUIRectCorner(self.corners)];
}

- (UIImage *)transformedImageWithImage:(UIImage *)sourceImage {
    if (self.radius < 1.0 / [UIScreen mainScreen].scale) {
        // don't round unroundable radius :)
        return sourceImage;
    }
    
    // voila! magic!..
    UIImage *drawnImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(sourceImage.size, NO, sourceImage.scale);
        CGRect rect = CGRectMake(0.0, 0.0, sourceImage.size.width, sourceImage.size.height);
        [[UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:self.corners cornerRadii:CGSizeMake(self.radius, self.radius)] addClip];
        [sourceImage drawInRect:rect];
        drawnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return drawnImage;
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %@>", [super description], self.transformationName];
}

@end

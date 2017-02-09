//
//  MACornerImageTransformation.m
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/3/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import "MACornerImageTransformation.h"

@implementation MACornerImageTransformation

#pragma mark - initialization

- (instancetype)initWithCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    if (self = [super init]) {
        self.corners = corners;
        self.radius = radius;
    }
    return self;
}

+ (instancetype)transformationWithRadius:(CGFloat)radius {
    return [[self alloc] initWithCorners:UIRectCornerAllCorners radius:radius];
}

#pragma mark - helpers

- (NSString *)stringForCorners:(UIRectCorner)corners {
    NSMutableString *string = [NSMutableString string];
    NSDictionary *mapping = @{
                              @(UIRectCornerBottomLeft) : @"bl",
                              @(UIRectCornerBottomRight) : @"br",
                              @(UIRectCornerTopLeft) : @"tl",
                              @(UIRectCornerTopRight) : @"tr"
                              };
    
    for (NSNumber *number in mapping.allKeys) {
        if (corners && number.integerValue) {
            [string appendString:mapping[number]];
        }
    }
    return string;
}

#pragma mark - MAImageTransformation

- (NSString *)transformationName {
    return [NSString stringWithFormat:@"corner_%.0f_%@", self.radius, [self stringForCorners:self.corners]];
}

- (UIImage *)applyTransformationToImage:(UIImage *)sourceImage {
    if (self.radius < 1.0 / [UIScreen mainScreen].scale) {
        // don't round unroundable radius :)
        return sourceImage;
    } else {
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
}

@end

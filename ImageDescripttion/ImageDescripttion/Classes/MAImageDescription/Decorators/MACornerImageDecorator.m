//
//  MACornerImageDecorator.m
//  ImageDescription
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import "MACornerImageDecorator.h"

@implementation MACornerImageDecorator

- (instancetype)initWithCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    if (self = [super init]) {
        self.corners = corners;
        self.radius = radius;
    }
    return self;
}

+ (instancetype)decoratorWithRadius:(CGFloat)radius {
    return [[self alloc] initWithCorners:UIRectCornerAllCorners radius:radius];
}

#pragma mark -

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

- (NSString *)transformName {
    return [NSString stringWithFormat:@"corner_%.0f_%@", self.radius, [self stringForCorners:self.corners]];
}

#pragma mark -

- (UIImage *)decoratedImage:(UIImage *)image {
    UIImage *drawnImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        CGRect rect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        [[UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:self.corners cornerRadii:CGSizeMake(self.radius, self.radius)] addClip];
        [image drawInRect:rect];
        drawnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return drawnImage;
}

@end

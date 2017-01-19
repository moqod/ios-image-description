//
//  MAImageDecorator.h
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import "MABaseImageDecorator.h"

@implementation MABaseImageDecorator

- (UIImage *)decoratedImage:(UIImage *)image {
    return image;
}

#pragma mark -

- (NSString *)transformName {
    return @"empty";
}

#pragma mark -

- (BOOL)isEqual:(MABaseImageDecorator *)object {
    return [object isKindOfClass:[MABaseImageDecorator class]] && [self.transformName isEqualToString:object.transformName];
}

@end

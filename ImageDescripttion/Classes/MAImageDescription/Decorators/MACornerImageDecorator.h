//
//  MACornerImageDecorator.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import "MABaseImageDecorator.h"

/**
 *  Rounds corners :)
 */
@interface MACornerImageDecorator : MABaseImageDecorator

@property (nonatomic, assign) CGFloat           radius;
@property (nonatomic, assign) UIRectCorner      corners;

- (instancetype)initWithCorners:(UIRectCorner)corners radius:(CGFloat)radius;

+ (instancetype)decoratorWithRadius:(CGFloat)radius;

@end

//
//  MACornerImageTransformation.h
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/3/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAImageTransformation.h"

/**
 *  Rounds specified corners with given radius.
 */
@interface MACornerImageTransformation : NSObject <MAImageTransformation>

// Rounded corner radius
@property (nonatomic, assign) CGFloat           radius;

// Rounded corner options
@property (nonatomic, assign) UIRectCorner      corners;

- (instancetype)initWithCorners:(UIRectCorner)corners radius:(CGFloat)radius;

// Corners is `UIRectCornerAllCorners`
+ (instancetype)transformationWithRadius:(CGFloat)radius;

@end

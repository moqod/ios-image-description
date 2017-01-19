//
//  MAImageDecorator.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 3/4/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Decorates an image.
 */
@protocol MAImageDecorator <NSObject>

// Decoration name
@property (nonatomic, readonly) NSString    *transformName;

/**
 *  Decorates an image :)
 *
 *  @param image Original image
 *
 *  @return Decorated image
 */
- (UIImage *)decoratedImage:(UIImage *)image;

@end

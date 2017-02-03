//
//  MAImageTransformation.h
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/3/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Applies transformation to an image.
 */
@protocol MAImageTransformation <NSObject>

@property (nonatomic, readonly) NSString        *transformationName;

// Applies transformation and return result image.
- (UIImage *)applyTransformation:(UIImage *)sourceImage;

@end

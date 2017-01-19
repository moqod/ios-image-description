//
//  MAImageHelper.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 3/1/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

// Author is Matt!
typedef enum {
    MGImageResizeCrop,	// analogous to UIViewContentModeScaleAspectFill, i.e. "best fit" with no space around.
    MGImageResizeCropStart,
    MGImageResizeCropEnd,
    MGImageResizeScale	// analogous to UIViewContentModeScaleAspectFit, i.e. scale down to fit, leaving space around if necessary.
} MGImageResizingMethod;

// Temporary solution, we need all these small functions somewhere, maybe inside decorators?
@interface MAImageHelper : NSObject

// offscreen drawing
+ (UIImage *)offscreenDrawnImage:(UIImage *)lazyLoadedImage;

// resize
+ (UIImage *)imageToFitSize:(CGSize)size method:(MGImageResizingMethod)resizeMethod image:(UIImage *)image;
+ (UIImage *)imageToFitSize:(CGSize)fitSize method:(MGImageResizingMethod)resizeMethod image:(UIImage *)image usePixels:(BOOL)usePixels;

+ (UIImage *)imageCroppedToFitSize:(CGSize)size image:(UIImage *)image; // uses MGImageResizeCrop
+ (UIImage *)imageScaledToFitSize:(CGSize)size image:(UIImage *)image; // uses MGImageResizeScale

@end

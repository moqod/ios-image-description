//
//  MAImageHelper.m
//  ImageDescription
//
//  Created by Andrew Kopanev on 3/1/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAImageHelper.h"

@implementation MAImageHelper

#pragma mark - offscreen drawing

+ (UIImage *)offscreenDrawnImage:(UIImage *)lazyLoadedImage { //NOTE: it uses too mach memory(2mb(1024p)->30mb)
    UIImage *drawnImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(lazyLoadedImage.size, NO, 0.0);
        [lazyLoadedImage drawAtPoint:CGPointZero];
        drawnImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return drawnImage;
}

#pragma mark - resize

+ (UIImage *)imageToFitSize:(CGSize)size method:(MGImageResizingMethod)resizeMethod image:(UIImage *)image {
    return [self imageToFitSize:size method:resizeMethod image:image usePixels:NO];
}

+ (UIImage *)imageToFitSize:(CGSize)fitSize method:(MGImageResizingMethod)resizeMethod image:(UIImage *)image usePixels:(BOOL)usePixels {
    float imageScaleFactor = image.scale;
    
    float sourceWidth = image.size.width * imageScaleFactor;
    float sourceHeight = image.size.height * imageScaleFactor;
    float targetWidth = fitSize.width;
    float targetHeight = fitSize.height;
    BOOL cropping = resizeMethod != MGImageResizeScale;
    
    // Calculate aspect ratios
    float sourceRatio = sourceWidth / sourceHeight;
    float targetRatio = targetWidth / targetHeight;
    
    // Determine what side of the source image to use for proportional scaling
    BOOL scaleWidth = sourceRatio <= targetRatio;
    // Deal with the case of just scaling proportionally to fit, without cropping
    scaleWidth = cropping ? scaleWidth : !scaleWidth;
    
    // Proportionally scale source image
    float scalingFactor, scaledWidth, scaledHeight;
    if (scaleWidth) {
        scalingFactor = 1.0 / sourceRatio;
        scaledWidth = targetWidth;
        scaledHeight = round(targetWidth * scalingFactor);
    } else {
        scalingFactor = sourceRatio;
        scaledWidth = round(targetHeight * scalingFactor);
        scaledHeight = targetHeight;
    }
    float scaleFactor = scaledHeight / sourceHeight;
    
    // Calculate compositing rectangles
    CGRect sourceRect, destRect;
    if (cropping) {
        destRect = CGRectMake(0, 0, targetWidth, targetHeight);
        float destX = 0.0f;
        float destY = 0.0f;
        if (resizeMethod == MGImageResizeCrop) {
            // Crop center
            destX = round((scaledWidth - targetWidth) / 2.0);
            destY = round((scaledHeight - targetHeight) / 2.0);
        } else if (resizeMethod == MGImageResizeCropStart) {
            // Crop top or left (prefer top)
            if (scaleWidth) {
                // Crop top
                destX = 0.0;
                destY = 0.0;
            } else {
                // Crop left
                destX = 0.0;
                destY = round((scaledHeight - targetHeight) / 2.0);
            }
        } else if (resizeMethod == MGImageResizeCropEnd) {
            // Crop bottom or right
            if (scaleWidth) {
                // Crop bottom
                destX = round((scaledWidth - targetWidth) / 2.0);
                destY = round(scaledHeight - targetHeight);
            } else {
                // Crop right
                destX = round(scaledWidth - targetWidth);
                destY = round((scaledHeight - targetHeight) / 2.0);
            }
        }
        sourceRect = CGRectMake(destX / scaleFactor, destY / scaleFactor,
                                targetWidth / scaleFactor, targetHeight / scaleFactor);
    } else {
        sourceRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
        destRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
    }
    
    // Create appropriately modified image.
    UIImage *resizedImage = nil;
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions(destRect.size, NO, usePixels ? 1.0f : 0.0f); // 0.f for scale means "scale for device's main screen".
        CGImageRef sourceImg = CGImageCreateWithImageInRect([image CGImage], sourceRect); // cropping happens here.
        resizedImage = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:image.imageOrientation]; // create cropped UIImage.
        
        CGImageRelease(sourceImg);
        [resizedImage drawInRect:destRect]; // the actual scaling happens here, and orientation is taken care of automatically.
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (!resizedImage) {
            // Try older method.
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(NULL, scaledWidth, scaledHeight, 8, (scaledWidth * 4), colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
            CGImageRef sourceImg = CGImageCreateWithImageInRect([image CGImage], sourceRect);
            CGContextDrawImage(context, destRect, sourceImg);
            CGImageRelease(sourceImg);
            CGImageRef finalImage = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            CGColorSpaceRelease(colorSpace);
            resizedImage = [UIImage imageWithCGImage:finalImage];
            CGImageRelease(finalImage);
        }
    }
    return resizedImage;
}

+ (UIImage *)imageCroppedToFitSize:(CGSize)size image:(UIImage *)image {
    return [self imageToFitSize:size method:MGImageResizeCrop image:image];
}

+ (UIImage *)imageScaledToFitSize:(CGSize)size image:(UIImage *)image {
    return [self imageToFitSize:size method:MGImageResizeScale image:image];
}

@end

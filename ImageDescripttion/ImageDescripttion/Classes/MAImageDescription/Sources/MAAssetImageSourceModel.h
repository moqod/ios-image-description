//
//  MAAssetImageSourceModel.h
//  AirCam
//
//  Created by Andrew Kopanev on 3/7/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MAImageSource.h"

/**
 *  Uses `- requestImageForAsset:targetSize:contentMode:options:resultHandler:` for getting an image.
 *  Skips low-quality images, tries to download an image from iCloud (if image located there).
 */
@interface MAAssetImageSourceModel : NSObject <MAImageSource>

@property (nonatomic, readonly) PHAsset     *photoAsset;
@property (nonatomic, readonly) CGSize      targetSize;

// Default is `PHImageContentModeAspectFit`
@property (nonatomic, assign) PHImageContentMode    contentMode;

- (instancetype)initWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;

@end

//
//  MAResizeImageTransformation.h
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/3/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import "MAImageTransformation.h"

typedef NS_ENUM(NSInteger, MAResizeType) {
    MAResizeAspectFill,
    MAResizeAspectFit
};

/**
 *  Resizes an image.
 */
@interface MAResizeImageTransformation : NSObject <MAImageTransformation>

// Default is `MAResizeAspectFill`
@property (nonatomic, assign) MAResizeType  resizeType;

// Default is CGSizeZero
@property (nonatomic, assign) CGSize        size;

- (instancetype)initWithSize:(CGSize)size resizeType:(MAResizeType)resizeType;

// Resize type is `MAResizeAspectFill`
+ (instancetype)transformationWithSize:(CGSize)size;

@end

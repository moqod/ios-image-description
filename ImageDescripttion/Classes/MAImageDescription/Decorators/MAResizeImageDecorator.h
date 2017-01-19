//
//  MAResizeImageDecorator.h
//  MAImageCrop
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import "MABaseImageDecorator.h"

typedef NS_ENUM(NSInteger, MAResizeType) {
    MAResizeAspectFill,
    MAResizeAspectFit
};

@interface MAResizeImageDecorator : MABaseImageDecorator

// Default is `MAResizeAspectFill`
@property (nonatomic, assign) MAResizeType  resizeType;

// Default is CGSizeZero
@property (nonatomic, assign) CGSize        size;

- (instancetype)initWithSize:(CGSize)size;

@end

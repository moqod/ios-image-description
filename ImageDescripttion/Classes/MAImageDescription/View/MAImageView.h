//
//  MAImageView.h
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/9/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImageDescription.h"

@interface MAImageView : UIView

@property (nonatomic, strong) MAImageDescription    *imageDescription;

@property (nonatomic, strong) UIImage               *placeholderImage;

// If YES then placeholder image removed from superview when original image is loaded
// Default is YES
@property (nonatomic, assign) BOOL                  hidesPlaceholderImage;

// If YES then the view adds (or replaces if exist) resize transformation on frame changes and reproduce an image
// Default is NO
@property (nonatomic, assign) BOOL                  updatesOnLayoutChanges;

@property (nonatomic, readonly) UIImage             *image;

// Uses simple fade animation
- (void)setImageDescription:(MAImageDescription *)imageDescription animated:(BOOL)animated;

@end

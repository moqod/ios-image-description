//
//  MAImageView.h
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/9/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImageDescription.h"

@class MAImageView;
@protocol MAImageViewDelegate <NSObject>

@optional
- (void)imageView:(MAImageView *)imageView didLoadImageWithDescription:(MAImageDescription *)imageDescription;
- (void)imageView:(MAImageView *)imageView didFailWithError:(NSError *)error imageDescription:(MAImageDescription *)imageDescription;

// Progress in range 0..1
- (void)imageView:(MAImageView *)imageView didUpdateProgress:(CGFloat)progress imageDescription:(MAImageDescription *)imageDescription;

@end

@interface MAImageView : UIView

@property (nonatomic, strong) MAImageDescription    *imageDescription;

@property (nonatomic, strong) UIImage               *placeholderImage;

// If YES then placeholder image removed from superview when original image is loaded
// Default is YES
@property (nonatomic, assign) BOOL                  hidesPlaceholderImage;

// If YES then the view adds (or replaces if exist) resize transformation on frame changes and reproduce an image
// Default is YES
@property (nonatomic, assign) BOOL                  updatesOnLayoutChanges;

// `nil` until loaded
@property (nonatomic, readonly) UIImage             *image;

@property (nonnull, weak) id <MAImageViewDelegate> delegate;

// Uses simple fade animation
- (void)setImageDescription:(MAImageDescription *)imageDescription animated:(BOOL)animated;

@end

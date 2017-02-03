//
//  MAImageView.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImageDescription.h"

@class MAImageView;
@protocol MAImageViewDelegate <NSObject>

@optional
- (void)imageViewWillLoadImage:(MAImageView *)imageView;
- (void)imageViewDidLoadImage:(MAImageView *)imageView;
- (void)imageView:(MAImageView *)imageView didFailWithError:(NSError *)error;

@end

@interface MAImageView : UIImageView

@property (nonatomic, strong) UIImage       *placeholderImage;
@property (nonatomic, weak) id <MAImageViewDelegate>delegate;

// Defaults to YES
@property (nonatomic, assign) BOOL                          loadsCachedImagesAsynchronusly;

// Defaults to NO
@property (nonatomic, assign) BOOL                          hidesPlaceholderImage;


// default is YES
@property (nonatomic, assign) BOOL          automaticallyResizesImage;

@property (nonatomic, strong) MAImageDescription        *imageDescription;
- (void)setImageDescription:(MAImageDescription *)imageDescription animated:(BOOL)animated;

@end

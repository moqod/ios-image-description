//
//  MAImageView.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImageDescription.h"

@class MAImageView_Old;
@protocol MAImageViewDelegate <NSObject>

@optional
- (void)imageViewWillLoadImage:(MAImageView_Old *)imageView;
- (void)imageViewDidLoadImage:(MAImageView_Old *)imageView;
- (void)imageView:(MAImageView_Old *)imageView didFailWithError:(NSError *)error;

@end

@interface MAImageView_Old : UIImageView

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

// placeholder / insert resize decorator to fit the frame

@end

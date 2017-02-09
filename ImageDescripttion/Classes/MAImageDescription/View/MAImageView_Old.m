//
//  MAImageView.m
//  ImageDescription
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import "MAImageView_Old.h"
#import "MAImageProducer.h"

@interface MAImageView_Old ()

@property (nonatomic, readonly) UIImageView     *placeholderImageView;
@property (nonatomic, readonly) UIImageView     *originalImageView;
@property (nonatomic, assign) BOOL              showImageAnimated;

@end

@implementation MAImageView_Old


#pragma mark - notifications

- (void)didLoadImageNotification:(NSNotification *)notification {
    if (![notification.name isEqualToString:self.imageDescription.imageFilePath]) {
        return; // skip outdated notifications
    }
    [self handleImage:notification.userInfo[@"result"] error:notification.userInfo[@"error"] userInfo:notification.userInfo];
}

- (void)handleImage:(UIImage *)image error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (image) {
        self.image = image;
        
        // seems like we don't need animation when image loaded from cache
        BOOL showAnimated = self.showImageAnimated; // (self.showImageAnimated && ![userInfo[@"cache"] boolValue]);
        if (showAnimated) {
            self.originalImageView.alpha = 0.0;
            [UIView animateWithDuration:0.2 delay:0.0 options:0 //UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.originalImageView.alpha = 1.0;
                             } completion:nil];
        } else {
            self.originalImageView.alpha = 1.0;
        }
        
        if ([self.delegate respondsToSelector:@selector(imageViewDidLoadImage:)]) {
            [self.delegate imageViewDidLoadImage:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(imageView:didFailWithError:)]) {
            [self.delegate imageView:self didFailWithError:error];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.imageDescription.imageFilePath object:nil];
}

#pragma mark - initialization

- (void)innerInitialization {
    self.automaticallyResizesImage = YES;
    self.loadsCachedImagesAsynchronusly = YES;
    self.hidesPlaceholderImage = NO;
    
    _placeholderImageView = [UIImageView new];
    [self addSubview:self.placeholderImageView];
    
    _originalImageView = [UIImageView new];
    [self addSubview:self.originalImageView];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self innerInitialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self innerInitialization];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - geometry


- (void)setFrame:(CGRect)frame {
    BOOL sizesIsEqual = CGSizeEqualToSize(self.frame.size, frame.size);
    [super setFrame:frame];
    
    if (self.imageDescription && !sizesIsEqual && !CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        self.image = nil;
        [self loadImageWithDescription];
    }
}

#pragma mark -

- (UIImage *)image {
    return self.originalImageView.image ?: self.placeholderImage;
}

- (void)setImage:(UIImage *)image {
    self.originalImageView.image = image;
    
    if (self.hidesPlaceholderImage) {
        self.placeholderImageView.hidden = image ? YES : NO;
    } else {
        self.placeholderImageView.hidden = NO;
    }
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    self.placeholderImageView.image = placeholderImage;
    if (!self.originalImageView.image) {
        self.placeholderImageView.hidden = NO;
    }
}

- (void)setHidesPlaceholderImage:(BOOL)hidesPlaceholderImage {
    _hidesPlaceholderImage = hidesPlaceholderImage;
    self.image = self.originalImageView.image;
}

#pragma mark -

- (void)setImageDescription:(MAImageDescription *)imageDescription {
    [self setImageDescription:imageDescription animated:NO];
}

- (void)setImageDescription:(MAImageDescription *)imageDescription animated:(BOOL)animated {
    if (![_imageDescription.imageFilePath isEqualToString:imageDescription.imageFilePath]) {
        
        self.showImageAnimated = animated;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[_imageDescription imageFilePath] object:nil];
        [[MAImageProducer defaultProducer] cancelProducingImageWithDescription:_imageDescription];
        
        _imageDescription = imageDescription;
        self.image = nil;
        
        if (_imageDescription) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoadImageNotification:) name:[_imageDescription imageFilePath] object:nil];
            [self loadImageWithDescription];
        }
    }
}

- (void)loadImageWithDescription {
    if (self.imageDescription) {
        // append size decorator here please!
        if (self.automaticallyResizesImage) {
            // TODO: insert resize decorator here please
            // TODO: !!!
        }
        
        if ([self.delegate respondsToSelector:@selector(imageViewWillLoadImage:)]) {
            [self.delegate imageViewWillLoadImage:self];
        }
        
        if (!self.loadsCachedImagesAsynchronusly && [[NSFileManager defaultManager] fileExistsAtPath:self.imageDescription.imageFilePath]) {
            self.showImageAnimated = NO;
            [self handleImage:[UIImage imageWithContentsOfFile:self.imageDescription.imageFilePath] error:nil userInfo:@{ @"cache" : @YES }];
        } else {
            [[MAImageProducer defaultProducer] produceImageWithDescription:self.imageDescription];
        }
    }
}

#pragma mark -

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    self.placeholderImageView.contentMode = self.originalImageView.contentMode = contentMode;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderImageView.frame = self.originalImageView.frame = self.bounds;
}

@end

//
//  MAImageView.m
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/9/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import "MAImageView.h"

#import "MAResizeImageTransformation.h"
#import "MAImageProducer.h"

@interface MAImageView ()

@property (nonatomic, readonly) UIImageView         *placeholderImageView;
@property (nonatomic, readonly) UIImageView         *resultImageView;

@property (nonatomic, strong) MAImageDescription    *realImageDescription;

@property (nonatomic, assign) BOOL                  showImageAnimated;

@end

@implementation MAImageView

#pragma mark - notifications

- (void)imageNotification:(NSNotification *)notification {
    // voiila!..
    
    // rare case but...
    if (![notification.name isEqualToString:[[MAImageProducer defaultProducer] notificationNameForImageDescription:self.realImageDescription]]) {
        return; // skip outdated notifications
    }
    
    [self handleImage:notification.userInfo[@"result"] error:notification.userInfo[@"error"] userInfo:notification.userInfo];
    
    // unsubscribe
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[[MAImageProducer defaultProducer] notificationNameForImageDescription:self.realImageDescription] object:nil];
}

- (void)handleImage:(UIImage *)image error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    if (image) {
        self.resultImageView.image = image;
        
        // seems like we don't need animation when image loaded from cache
        // BOOL showAnimated = self.showImageAnimated; // (self.showImageAnimated && ![userInfo[@"cache"] boolValue]);
        if (self.showImageAnimated) {
            self.resultImageView.alpha = 0.0;
            [UIView animateWithDuration:6.2 delay:0.0 options:0 //UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 self.resultImageView.alpha = 1.0;
                             } completion:^(BOOL finished) {
                                 self.placeholderImageView.alpha = 0.0;                                 
                             }];
        } else {
            self.resultImageView.alpha = 1.0;
        }
    } else {
        
    }
}


#pragma mark - initialization

- (void)innerInitialization {
    self.updatesOnLayoutChanges = NO;
    
    _placeholderImageView = [UIImageView new];
    [self addSubview:self.placeholderImageView];
    
    _resultImageView = [UIImageView new];
    [self addSubview:self.resultImageView];
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

#pragma mark - placeholder image

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    self.placeholderImageView.image = _placeholderImage;
}

#pragma mark - setters

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    self.placeholderImageView.contentMode = self.resultImageView.contentMode = contentMode;
}

- (void)setImageDescription:(MAImageDescription *)imageDescription {
    [self setImageDescription:imageDescription animated:NO];
}

- (void)setRealImageDescription:(MAImageDescription *)realImageDescription {
    MAImageProducer *producer = [MAImageProducer defaultProducer];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if (_realImageDescription) {
        [notificationCenter removeObserver:self name:[producer notificationNameForImageDescription:_realImageDescription] object:nil];
    }
    _realImageDescription = realImageDescription;
    if (_realImageDescription) {
        [notificationCenter addObserver:self selector:@selector(imageNotification:) name:[producer notificationNameForImageDescription:_realImageDescription] object:nil];
    }
}

- (void)setImageDescription:(MAImageDescription *)imageDescription animated:(BOOL)animated {
    _imageDescription = imageDescription;
    self.showImageAnimated = animated;
    
    MAImageDescription *realImageDescription = [self realImageDescriptionForOriginalImageDescription:imageDescription];
    if (realImageDescription && ![self.realImageDescription isEqual:realImageDescription]) {
        self.realImageDescription = realImageDescription;
        // load it I guess!..
        [self loadImageDescription];
    } else {
        self.realImageDescription = nil;
    }
}

#pragma mark - image loading

- (void)loadImageDescription {
    // reset current image?
    self.resultImageView.image = nil;
    
    // show placeholder?
    [[MAImageProducer defaultProducer] produceImageWithDescription:self.realImageDescription];
}

#pragma mark - helpers

- (MAImageDescription *)realImageDescriptionForOriginalImageDescription:(MAImageDescription *)imageDescription {
    if (self.updatesOnLayoutChanges) {
        // remove existing resize transformation
        NSMutableArray *transformations = [NSMutableArray array];
        for (id <MAImageTransformation> transformation in imageDescription.transformations) {
            if (![transformation isKindOfClass:[MAResizeImageTransformation class]]) {
                [transformations addObject:transformation];
            }
        }
        
        // insert resize transformation
        if (!CGSizeEqualToSize(CGSizeZero, self.bounds.size)) {
            MAResizeImageTransformation *t = [MAResizeImageTransformation transformationWithSize:self.bounds.size];
            [transformations insertObject:t atIndex:0];
        }
        
        MAImageDescription *realDescription = [[MAImageDescription alloc] initWithSourceModel:imageDescription.sourceModel transformations:transformations];
        realDescription.imageFilePath = imageDescription.imageFilePath.copy;
        realDescription.loadingQueueAlias = imageDescription.loadingQueueAlias.copy;
        return realDescription;
    } else {
        return imageDescription;
    }
}

#pragma mark - layout

- (void)setFrame:(CGRect)frame {
    BOOL sizesAreEqual = CGSizeEqualToSize(self.frame.size, frame.size);
    [super setFrame:frame];
    
    if (!CGSizeEqualToSize(self.frame.size, CGSizeZero) && self.realImageDescription && !sizesAreEqual) {
        [self setImageDescription:_imageDescription animated:self.showImageAnimated];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.resultImageView.frame = self.placeholderImageView.frame = self.bounds;
}

@end

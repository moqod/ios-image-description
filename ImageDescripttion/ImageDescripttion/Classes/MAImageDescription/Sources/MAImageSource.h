//
//  MAImageSource.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 3/1/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

// errors
extern NSString *const MAImageSourceErrorDomain;

typedef NS_ENUM(NSInteger, ASImageSourceError) {
    MAImageSourceErrorFileDoesNotExist = 1,
    MAImageSourceErrorFileIsNotAnImage = 2,
};

typedef void (^MAImageCompletionBlock_t)(UIImage *image, NSError *error);

@protocol MAImageSource <NSObject>

@required
@property (nonatomic, readonly) NSString                    *resultImageName;

// Perfroms action in background thread, completion called in main thread always
- (void)imageWithCompletion:(MAImageCompletionBlock_t)completion;

- (BOOL) isEqualToImageSource:(id<MAImageSource>)model;

@optional
// YES if not implemented
@property (nonatomic, readonly) BOOL                        isRelativelyFast;

@end

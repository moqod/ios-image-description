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

@protocol MAImageSource <NSObject>


@property (nonatomic, readonly) NSString                    *resultImageName;

// Perfroms action in background thread
// Completion called in Main thread
- (void)imageWithCompletion:(void (^)(UIImage *image, NSError *error))completion;

@end

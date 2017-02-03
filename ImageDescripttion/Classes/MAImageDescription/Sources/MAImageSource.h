//
//  MAImageSource.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 3/1/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MAImageSource <NSObject>

@property (nonatomic, readonly) NSString                    *sourceName;

// Could perform action on background thread
// Completion called on main thread
- (void)imageWithCompletion:(void (^)(UIImage *image, NSError *error))completion;

@end

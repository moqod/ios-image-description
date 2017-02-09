//
//  MAImageDescriptionOperation.h
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAImageDescription.h"

@class MAImageDescriptionLoadingOperation;
@protocol MAImageDescriptionLoadingOperationDelegate <NSObject>

@optional
- (void)loadingOperation:(MAImageDescriptionLoadingOperation *)operation didLoadImage:(UIImage *)image forImageDescription:(MAImageDescription *)imageDescription fromCache:(BOOL)fromCache;
- (void)loadingOperation:(MAImageDescriptionLoadingOperation *)operation didFailWithError:(NSError *)error forImageDescription:(MAImageDescription *)imageDescription;

@end

// Loads or produces an image for given description.
@interface MAImageDescriptionLoadingOperation : NSOperation

@property (nonatomic, readonly) MAImageDescription     *imageDescription;
@property (nonatomic, weak) id <MAImageDescriptionLoadingOperationDelegate> delegate;

+ (instancetype)operationWithDescription:(MAImageDescription *)imageDescription;

@end

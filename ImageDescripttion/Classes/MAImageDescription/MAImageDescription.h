//
//  MAImageDescription.h
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImageSource.h"
#import "MAImageTransformation.h"
#import "MAErrors.h"

@class MAResizeImageTransformation;

/**
 *  Describes an image source and transformations. 
 *  Complex images with inline caching in just a few code lines. Lovely!
 */
@interface MAImageDescription : NSObject <NSCopying>

// Image source (file, URL, other)
@property (nonatomic, readonly) id <MAImageSource>                    sourceModel;

// Transformations, could be nil
@property (nonatomic, readonly) NSArray <MAResizeImageTransformation *>                             *transformations;

// Default is `temporary_folder/sourceModel_transformation1_..._transformationN`
// Set your own value if suitable
@property (nonatomic, strong) NSString                              *imageFilePath;

// Default is `default`.
// If there is no operation queue with `loadingQueueAlias` then new queue will be created.
// See `MAImageProducer` for more details.
@property (nonatomic, strong) NSString                              *loadingQueueAlias;

// initialization
- (instancetype)initWithSourceModel:(id <MAImageSource>)sourceModel
                    transformations:(NSArray <MAResizeImageTransformation *> *)transformations;

@end

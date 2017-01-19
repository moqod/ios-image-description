//
//  MAImageDescription.h
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImageSource.h"
#import "MAImageDecorator.h"

/**
 *  Images Loading, creation and decorating with just a few code lines. Lovely!
 *  Note: Sends notification named `self.resultImageName` through `[NSNotificationCenter defaultCenter]` when completed
 */
@interface MAImageDescription : NSObject

// Image source (file, URL, other)
@property (nonatomic, strong) id <MAImageSource>            sourceModel;

// Decorators, could be nil or empty
@property (nonatomic, strong) NSArray               <MAImageDecorator> *decorators;

// Composite result image name, also uses as notification name
@property (nonatomic, readonly) NSString                    *resultImageName;

// Full path to cached file
@property (nonatomic, readonly) NSString                    *resultImageFilePath;

// initialization
- (instancetype)initWithSourceModel:(id <MAImageSource>)sourceModel decorators:(NSArray *)decorators;

// Useful for loading images from bundle (creates file source model like `[UIImage imageNamed:fileName]`
+ (instancetype)descriptionWithImageNamed:(NSString *)fileName;

// produces an image
- (void)imageWithCompletion:(MAImageCompletionBlock_t)completion;
- (BOOL)cacheExists;

@end

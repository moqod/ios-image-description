//
//  MAFilePathImageSourceModel.h
//
//  Created by Andrew Kopanev on 3/1/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAImageSource.h"

/**
 *  Loads an image at file path.
 */
@interface MAFileImageSourceModel : NSObject <MAImageSource>

@property (nonatomic, readonly) NSString                 *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath;

// handy constructors
// uses [[NSBundle mainBundle] pathForResource:imageName ofType:nil]
+ (instancetype)sourceWithImageNamed:(NSString *)imageName;
+ (instancetype)sourceWithImagePath:(NSString *)imagePath;

@end

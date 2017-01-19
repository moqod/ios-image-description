//
//  MAURLImageSourceModel.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 3/7/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAImageSource.h"

@interface MAURLImageSourceModel : NSObject <MAImageSource>

// Custom destination directory path
@property (nonatomic, strong) NSString                  *destinationDirectoryPath;


@property (nonatomic, readonly) NSString                *cachedImageFilePath;

// Image URL
@property (nonatomic, readonly) NSURL                   *url;

// Custom image file name. Defaut value is [url lastPathComponent]
@property (nonatomic, strong) NSString                  *imageFileName;

- (instancetype)initWithURL:(NSURL *)url;

// Default is `NSTemporaryDirectory()`
+ (void)setDestinationDirectoryPath:(NSString *)destinationDirectoryPath;

@end

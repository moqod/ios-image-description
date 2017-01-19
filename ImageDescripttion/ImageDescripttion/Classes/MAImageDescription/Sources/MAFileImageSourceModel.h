//
//  MAFilePathImageSourceModel.h
//
//  Created by Andrew Kopanev on 3/1/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAImageSource.h"

typedef UIImage * (^MAFileImageSourceModelConfigBlock_t)(NSString *path);


@interface MAFileImageSourceModel : NSObject <MAImageSource>

@property (nonatomic, strong) NSString                 *filePath;
@property (nonatomic, copy) MAFileImageSourceModelConfigBlock_t configBlock;

- (instancetype)initWithFilePath:(NSString *)filePath;
- (instancetype)initWithFilePath:(NSString *)filePath andConfigBlock:(MAFileImageSourceModelConfigBlock_t)block;

// handy constructors
+ (instancetype)sourceWithImageNamed:(NSString *)imageName; // uses [[NSBundle mainBundle] pathForResource:imageName ofType:nil]
+ (instancetype)sourceWithImagePath:(NSString *)imagePath;

@end

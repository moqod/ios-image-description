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

// Image URL
@property (nonatomic, readonly) NSURL                   *url;

- (instancetype)initWithURL:(NSURL *)url;
+ (instancetype)sourceWithURL:(NSURL *)url;

@end

//
//  MAImageLoader.h
//  ImageDescription
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAImageDescription.h"

@interface MAImageProducer : NSObject

+ (instancetype)defaultProducer;

- (void)produceImageWithDescription:(MAImageDescription *)imageDescription;
- (void)cancelProducingImageWithDescription:(MAImageDescription *)imageDescription;

@end

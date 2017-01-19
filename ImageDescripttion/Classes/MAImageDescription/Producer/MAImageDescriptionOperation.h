//
//  MAImageDescriptionOperation.h
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAImageDescription.h"

@interface MAImageDescriptionOperation : NSOperation

@property (nonatomic, readonly) MAImageDescription     *imageDescription;

+ (instancetype)operationWithDescription:(MAImageDescription *)imageDescription;

@end

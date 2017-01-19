//
//  MAImageDecorator.h
//
//  Created by Andrew Kopanev on 8/5/15.
//  Copyright (c) 2015 MQD B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAImageDecorator.h"

/**
 *  Base decorator. 
 *  Returns origin image and does nothing.
 */
@interface MABaseImageDecorator : NSObject <MAImageDecorator>

@property (nonatomic, readonly) NSString    *transformName;

- (UIImage *)decoratedImage:(UIImage *)image;

@end

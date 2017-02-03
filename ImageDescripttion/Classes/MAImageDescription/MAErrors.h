//
//  MAErrors.h
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 2/3/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#ifndef MAErrors_h
#define MAErrors_h

// errors
extern NSString *const MAImageDescriptionErrorDomain;

typedef NS_ENUM(NSInteger, MAImageDescriptionError) {
    MASourceErrorFileDoesNotExist = 1,
    MASourceErrorFileIsNotAnImage = 2,
};

#endif /* MAErrors_h */
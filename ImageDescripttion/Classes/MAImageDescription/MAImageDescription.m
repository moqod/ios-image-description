//
//  MAImageDescription.m
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAImageDescription.h"

#import "MAFileImageSourceModel.h"

// constants
NSString *const MAImageSourceErrorDomain            = @"MAImageSourceErrorDomain";

@interface MAImageDescription ()

@property (nonatomic, strong) NSArray               *transformations;

@end

@implementation MAImageDescription

#pragma mark - initialization

- (instancetype)initWithSourceModel:(id <MAImageSource>)sourceModel transformations:(NSArray *)transformations {
    if (self = [super init]) {
        self.transformations = transformations;
        self.sourceModel = sourceModel;
        
        NSString *imageName = [self resultImageName];
        self.imageFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    }
    return self;
}

#pragma mark - helpers

- (NSString *)resultImageName {
    NSMutableString *imageName = [NSMutableString stringWithString:self.sourceModel.resultImageName ?: @""];
    for (id <MAImageTransformation> transformation in self.transformations) {
        [imageName appendFormat:@"%@%@", imageName.length ? @"_" : @"", transformation.transformationName];
    }
    return imageName;
}

#pragma mark - equtability

- (NSUInteger)hash {
    return [self.resultImageName hash];
}

- (BOOL)isEqual:(MAImageDescription *)object {
    return [object isKindOfClass:[self class]] && [self.resultImageName isEqualToString:object.resultImageName];
}

@end

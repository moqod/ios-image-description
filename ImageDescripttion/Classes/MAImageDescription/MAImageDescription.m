//
//  MAImageDescription.m
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAImageDescription.h"

#import "MAFileImageSourceModel.h"

// error domain
NSString *const MAImageDescriptionErrorDomain            = @"MAImageDescriptionErrorDomain";

@interface MAImageDescription ()

@property (nonatomic, strong) id <MAImageSource>    sourceModel;
@property (nonatomic, strong) NSArray               *transformations;

@end

@implementation MAImageDescription

#pragma mark - initialization

- (instancetype)initWithSourceModel:(id <MAImageSource>)sourceModel transformations:(NSArray *)transformations {
    if (self = [super init]) {
        self.transformations = transformations;
        self.sourceModel = sourceModel;
        self.loadingQueueAlias = @"default";
        
        NSString *imageName = [self resultImageName];
        self.imageFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    }
    return self;
}

#pragma mark - helpers

- (NSString *)resultImageName {
    NSMutableString *imageName = [NSMutableString stringWithString:self.sourceModel.sourceName ?: @""];
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

#pragma mark - copying

- (id)copyWithZone:(NSZone *)zone {
    MAImageDescription *instance = [[self class] allocWithZone:zone];
    instance.transformations = self.transformations.mutableCopy;
    instance.sourceModel = self.sourceModel;
    instance.loadingQueueAlias = self.loadingQueueAlias.copy;
    instance.imageFilePath = self.imageFilePath.copy;
    return instance;
}

@end

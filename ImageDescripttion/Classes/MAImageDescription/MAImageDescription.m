//
//  MAImageDescription.m
//
//  Created by Andrew Kopanev on 1/25/16.
//  Copyright © 2016 MQD B.V. All rights reserved.
//

#import "MAImageDescription.h"

#import "MAFileImageSourceModel.h"

// error domain
NSString *const MAImageDescriptionErrorDomain = @"MAImageDescriptionErrorDomain";

@interface MAImageDescription ()

@property (nonatomic, strong) id <MAImageSource> sourceModel;
@property (nonatomic, strong) NSArray <MAResizeImageTransformation *> *transformations;

@end

@implementation MAImageDescription

#pragma mark - initialization

- (instancetype)initWithSourceModel:(id <MAImageSource>)sourceModel transformations:(NSArray <MAResizeImageTransformation *> *)transformations {
    if (self = [super init]) {
        _transformations = transformations;
        _sourceModel = sourceModel;
        _loadingQueueAlias = @"default";
        
        NSString *imageName = [[self class] imageNameWithSourceMomdel:_sourceModel transformations:_transformations];
        _imageFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    }
    return self;
}

#pragma mark - helpers

+ (NSString *)imageNameWithSourceMomdel:(id <MAImageSource>)sourceModel transformations:(NSArray <MAResizeImageTransformation *> *)transformations {
    NSMutableString *imageName = [NSMutableString stringWithString:sourceModel.sourceName ?: @""];
    for (id <MAImageTransformation> transformation in transformations) {
        [imageName appendFormat:@"%@%@", imageName.length ? @"_" : @"", transformation.transformationName];
    }
    return imageName;
}

- (NSString *)resultImageName {
    return [[self class] imageNameWithSourceMomdel:self.sourceModel transformations:self.transformations];
}

#pragma mark - equtability

- (NSUInteger)hash {
    return [self.resultImageName hash];
}

- (BOOL)isEqual:(MAImageDescription *)object {
    return [object isKindOfClass:[self class]] && [self.resultImageName isEqualToString:object.resultImageName];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    MAImageDescription *instance = [[self class] allocWithZone:zone];
    instance.transformations = [_transformations copy];
    instance.sourceModel = [_sourceModel copyWithZone:zone];
    instance.loadingQueueAlias = [_loadingQueueAlias copy];
    instance.imageFilePath = [_imageFilePath copy];
    return instance;
}

@end

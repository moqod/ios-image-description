//
//  ViewController.m
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 1/19/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import "ViewController.h"
#import "MAImageView.h"

#import "MAFileImageSourceModel.h"
#import "MAResizeImageTransformation.h"
#import "MACornerImageTransformation.h"

@interface ViewController ()

@property (nonatomic, readonly) MAImageView     *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    _imageView = [[MAImageView alloc] initWithFrame:CGRectInset(rect, 20.0f, 40.0f)];
   // self.imageView.delegate = self;
    [self.view addSubview:self.imageView];
    
    MAFileImageSourceModel *sourceModel = [MAFileImageSourceModel sourceWithImageNamed:@"image.png"];
    MAResizeImageTransformation *resizeDecorator = [MAResizeImageTransformation transformationWithSize:self.imageView.bounds.size];
    MACornerImageTransformation *cornerDecorator = [[MACornerImageTransformation alloc] initWithCorners:UIRectCornerTopLeft | UIRectCornerBottomRight radius:self.imageView.bounds.size.width * 0.4f];
    
    MAImageDescription *imageDescription = [[MAImageDescription alloc] initWithSourceModel:sourceModel transformations: @[ resizeDecorator, cornerDecorator ]];
    [self.imageView setImageDescription:imageDescription animated:YES];
}

@end

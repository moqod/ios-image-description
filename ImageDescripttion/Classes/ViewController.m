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
    
    srand((unsigned int)time(NULL));
    
    CGRect rect = [UIScreen mainScreen].bounds;
    _imageView = [[MAImageView alloc] initWithFrame:CGRectInset(rect, 20.0f, 40.0f)];
    self.imageView.updatesOnLayoutChanges = YES;
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.placeholderImage = [UIImage imageNamed:@"image.png"];
    [self.view addSubview:self.imageView];
    
    MAFileImageSourceModel *sourceModel = [MAFileImageSourceModel sourceWithImageNamed:@"hd_image.jpeg"];
    MAResizeImageTransformation *resizeDecorator = [MAResizeImageTransformation transformationWithSize:self.imageView.bounds.size];
    MACornerImageTransformation *cornerDecorator = [[MACornerImageTransformation alloc] initWithCorners:UIRectCornerTopLeft | UIRectCornerBottomRight radius:self.imageView.bounds.size.width * 0.4f];
    
    MAImageDescription *imageDescription = [[MAImageDescription alloc] initWithSourceModel:sourceModel transformations: @[ resizeDecorator, cornerDecorator ]];
    NSLog(@"file path == %@", imageDescription.imageFilePath);
    [self.imageView setImageDescription:imageDescription animated:YES];
}

- (CGFloat)random {
    return (rand() % 10000) / 10000.0f;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGRect bounds = self.view.bounds;
    CGRect frame = CGRectMake(20.0, 40.0, bounds.size.width * [self random] * 0.4 + bounds.size.width * 0.5, bounds.size.height * [self random] * 0.4 + bounds.size.height * 0.5);
    
    self.imageView.frame = frame;
}

@end

//
//  ViewController.m
//  ImageDescripttion
//
//  Created by Andrew Kopanev on 1/19/17.
//  Copyright © 2017 MQD BV. All rights reserved.
//

#import "ViewController.h"
#import "MAImageView.h"

@interface ViewController () <MAImageViewDelegate>

@property (nonatomic, readonly) MAImageView     *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    _imageView = [[MAImageView alloc] initWithFrame:CGRectInset(rect, 20.0f, 40.0f)];
    self.imageView.delegate = self;
    [self.view addSubview:self.imageView];
    
    MAURLImageSourceModel *sourceModel = [[MAURLImageSourceModel alloc] initWithURL:[NSURL URLWithString:@"https://upload.wikimedia.org/wikipedia/commons/5/58/Large_Pinus_glabra.jpg"]];
    MAResizeImageDecorator *resizeDecorator = [[MAResizeImageDecorator alloc] initWithSize:self.imageView.bounds.size];
    MACornerImageDecorator *cornerDecorator = [[MACornerImageDecorator alloc] initWithCorners:UIRectCornerTopLeft | UIRectCornerBottomRight radius:self.imageView.bounds.size.width * 0.4f];
    
    MAImageDescription *imageDescription = [[MAImageDescription alloc] initWithSourceModel:sourceModel decorators: @[ resizeDecorator, cornerDecorator ]];
    [self.imageView setImageDescription:imageDescription animated:YES];
}

#pragma mark -

- (void)imageViewWillLoadImage:(MAImageView *)imageView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)imageViewDidLoadImage:(MAImageView *)imageView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)imageView:(MAImageView *)imageView didFailWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end

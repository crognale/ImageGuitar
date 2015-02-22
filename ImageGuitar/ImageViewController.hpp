//
//  ImageViewController.h
//  ImageGuitar
//
//  Created by Sam Crognale on 2/21/15.
//  Copyright (c) 2015 Sam Crognale. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <opencv2/opencv.hpp>

@interface ImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) UIImage *image;



@end

//
//  ImageViewController.m
//  ImageGuitar
//
//  Created by Sam Crognale on 2/21/15.
//  Copyright (c) 2015 Sam Crognale. All rights reserved.
//

#include "UIImage2OpenCV.hpp"
#import "ImageViewController.hpp"
#import "AppDelegate.hpp"
#import "cvneon.hpp"

@interface ImageViewController ()

@end

@implementation ImageViewController

void getGray(const cv::Mat& input, cv::Mat& gray)
{
    const int numChannes = input.channels();
    
    if (numChannes == 4)
    {
#if TARGET_IPHONE_SIMULATOR
        cv::cvtColor(input, gray, cv::COLOR_BGRA2GRAY);
#else
        cv::neon_cvtColorBGRA2GRAY(input, gray);
#endif
        
    }
    else if (numChannes == 3)
    {
        cv::cvtColor(input, gray, cv::COLOR_BGR2GRAY);
    }
    else if (numChannes == 1)
    {
        gray = input;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.image = appDelegate.camImg;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
}

- (void)viewDidAppear:(BOOL)animated {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];


    cv::Mat color = [appDelegate.camImg toMat];
    cv::Mat gray;
    getGray(color, gray);
    
    cv::Mat grayColor;
    cv::cvtColor(gray, grayColor, cv::COLOR_GRAY2RGBA);
    self.imgView.image = [UIImage imageWithMat:grayColor andImageOrientation:UIImageOrientationRight];
    
    self.imgView.frame = appDelegate.window.frame;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

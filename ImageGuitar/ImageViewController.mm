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
    cv::Mat gray, output;
    getGray(color, gray);
    
    /*
    cv::Mat grayColor;
    cv::cvtColor(gray, grayColor, cv::COLOR_GRAY2RGBA);
    self.imgView.image = [UIImage imageWithMat:grayColor andImageOrientation:UIImageOrientationRight];
     */
    
    cv::Mat edges;
    cv::Canny(gray, edges, 50, 150);
    
    std::vector< std::vector<cv::Point> > c;
    
    cv::findContours(edges, c, cv::RETR_LIST, cv::CHAIN_APPROX_NONE);
    
    color.copyTo(output);
    cv::drawContours(output, c, -1, cv::Scalar(0,200,0));
    
    self.imgView.image = [UIImage imageWithMat:output andImageOrientation:UIImageOrientationRight];
    
    
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

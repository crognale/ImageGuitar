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

bool contourComp(std::vector<cv::Point> &a, std::vector<cv::Point> &b) {
    return a.size() > b.size();
}

- (void)viewDidAppear:(BOOL)animated {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    CGFloat newHeight = 400;
    CGFloat scaleFactor = newHeight / appDelegate.camImg.size.height;
    appDelegate.camImg = [self imageResize:appDelegate.camImg newHeight:newHeight newWidth: appDelegate.camImg.size.width * scaleFactor];
    NSLog(@"Img Size: h:%f w:%f\n",appDelegate.camImg.size.height, appDelegate.camImg.size.width);
    [self postImage:appDelegate.camImg];
    [self getLinesFromHTML];
    
    
    self.imgView.image = appDelegate.camImg;
    self.imgView.frame = appDelegate.window.frame;
    
    
}

-(void) postImage:(UIImage*) myImage {
    NSData *imageData = UIImageJPEGRepresentation(myImage,0.2);     //change Image to NSData
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.imogenquest.net/twitter/myDir/saveImageFromApp.php"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedfile\"; filename=\"test.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog([NSString stringWithFormat:@"Image Return String: %@", returnString]);
    
    
}

-(void) getLinesFromHTML {
    NSString *myURLString = @"https://www.wolframcloud.com/objects/72f8c3fa-516a-462a-9ab6-9084e88bb2ec?url=http%3A%2F%2Fwww.imogenquest.net%2Ftwitter%2FmyDir%2Fuploads%2Ftest.png";
    
    
    NSError *error = nil;
    NSURL *myURL = [NSURL URLWithString:myURLString];
    
    NSString *myHTMLString = [NSString stringWithContentsOfURL:myURL encoding:NSUTF8StringEncoding error:&error];
    myHTMLString = [myHTMLString stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    
    myHTMLString = [myHTMLString substringFromIndex:1];
    myHTMLString = [myHTMLString substringToIndex:[myHTMLString length] - 1];
    
    if (error != nil)
    {
        NSLog(@"Error : %@", error);
    }
    else
    {
        NSData *jsonData = [myHTMLString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error: &error];
        NSLog(@"%@\n",json);
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIImage *)imageResize :(UIImage*)img newHeight:(int)height newWidth:(int)width
{
    CGRect newFrame = CGRectMake(0, 0, width, height);
    CGFloat scale = [[UIScreen mainScreen]scale];
    /*You can remove the below comment if you dont want to scale the image in retina   device .Dont forget to comment UIGraphicsBeginImageContextWithOptions*/
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newFrame.size, NO, scale);
    [img drawInRect:CGRectMake(0,0,newFrame.size.width,newFrame.size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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

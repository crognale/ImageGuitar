//
//  ImageViewController.m
//  ImageGuitar
//
//  Created by Sam Crognale on 2/21/15.
//  Copyright (c) 2015 Sam Crognale. All rights reserved.
//

#import "ImageViewController.hpp"
#import "AppDelegate.hpp"
#import "LineView.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height / 2.0;
    CGFloat newHeight = screenHeight;
    CGFloat scaleFactor = newHeight / appDelegate.camImg.size.height;
    UIImage *smallImg = [self imageResize:appDelegate.camImg newHeight:newHeight newWidth: appDelegate.camImg.size.width * scaleFactor];
    NSLog(@"Img Size: h:%f w:%f\n",smallImg.size.height, smallImg.size.width);
    
    [self postImage:smallImg];
    NSArray *lineData = [self getLinesFromHTML];
    
    LineView *lv = [[LineView alloc] initWithFrame:self.view.frame];
    lv.lineData = lineData;
    [self.view addSubview:lv];
    [lv setNeedsDisplay];

}


- (void)viewWillAppear:(BOOL)animated{
}


- (void)viewDidAppear:(BOOL)animated {



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

-(NSArray *) getLinesFromHTML {
    NSString *myURLString = @"https://www.wolframcloud.com/objects/861b5731-6592-4b69-b9e6-8d6c8b7f4065?url=http%3A%2F%2Fwww.imogenquest.net%2Ftwitter%2FmyDir%2Fuploads%2Ftest.png";
    
    
    NSError *error = nil;
    NSURL *myURL = [NSURL URLWithString:myURLString];
    
    NSString *myHTMLString = [NSString stringWithContentsOfURL:myURL encoding:NSUTF8StringEncoding error:&error];
    myHTMLString = [myHTMLString stringByReplacingOccurrencesOfString:@"\\n" withString:@""];
    
    myHTMLString = [myHTMLString substringFromIndex:1];
    myHTMLString = [myHTMLString substringToIndex:[myHTMLString length] - 1];
    
    if (error != nil)
    {
        NSLog(@"Error : %@", error);
        return nil;
    }
    else
    {
        NSData *jsonData = [myHTMLString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error: &error];
        NSLog(@"%@\n",json);
        return json;

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

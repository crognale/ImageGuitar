//
//  ViewController.m
//  ImageGuitar
//
//  Created by Sam Crognale on 2/21/15.
//  Copyright (c) 2015 Sam Crognale. All rights reserved.
//

#import "ViewController.h"
#import <LLSimpleCamera/LLSimpleCamera.h>

@interface ViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *switchButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:CameraQualityPhoto andPosition:CameraPositionBack];
    
    //attach to view
    [self.camera attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];

    // capture
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            // we should stop the camera, since we don't need it anymore. We will open a new vc.
            // this very important, otherwise you may experience memory crashes
            [camera stop];
            /*
            // show the image
            ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];
            [self presentViewController:imageVC animated:NO completion:nil];
             */
        }
    }];
    
    //camera buttons
    self.snapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.snapButton.frame = CGRectMake(0, 0, 70.0f, 70.0f);
    self.snapButton.clipsToBounds = YES;
    self.snapButton.layer.cornerRadius = self.snapButton.frame.size.width / 2.0f;
    self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.snapButton.layer.borderWidth = 2.0f;
    self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.snapButton.center = self.view.center;
    CGRect rect = self.snapButton.frame;
    rect.origin = CGPointMake(rect.origin.x, self.view.frame.size.height - 15 - self.snapButton.frame.size.height);
    self.snapButton.frame = rect;

    [self.view addSubview:self.snapButton];

    
    self.switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchButton.frame = CGRectMake(0, 0, 29.0f + 20.0f, 22.0f + 20.0f);
    [self.switchButton setImage:[UIImage imageNamed:@"camera-switch.png"] forState:UIControlStateNormal];
    self.switchButton.imageEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchButton];
    
}

- (void)switchButtonPressed:(UIButton *)button {
    
    
    
}

- (void)snapButtonPressed:(UIButton *)button {
    
    // capture
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            
            // we should stop the camera, since we don't need it anymore. We will open a new vc.
            // this very important, otherwise you may experience memory crashes
            [camera stop];
            
            // show the image
        //    ImageViewController *imageVC = [[ImageViewController alloc] initWithImage:image];
          //  [self presentViewController:imageVC animated:NO completion:nil];
        }
    } exactSeenImage:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  LineView.m
//  ImageGuitar
//
//  Created by Sam Crognale on 2/22/15.
//  Copyright (c) 2015 Sam Crognale. All rights reserved.
//

#import "LineView.h"
#include "AppDelegate.hpp"
#import <AVFoundation/AVFoundation.h>

@interface LineView ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) NSMutableDictionary *pointDict;
@property (strong, nonatomic) NSMutableArray *avSounds;

@end

@implementation LineView


- (void)drawRect:(CGRect)rect {
    [[UIColor redColor] set];
    [self drawLines:self.lineData];
}


-(id) initWithFrame:(CGRect)r {
    self = [super initWithFrame:r];
    
    self.pointDict = [[NSMutableDictionary alloc] init];
    self.avSounds = [[NSMutableArray alloc] init];
      
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.img = appDelegate.camImg;
    
    self.imgView.image = appDelegate.camImg;
    self.imgView.frame = self.frame;
    
    [self drawLines:self.lineData];
    
    
    

    return self;
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
 //   CGPoint tappedPt = [[touches anyObject] locationInView: self];
    
    NSArray *tappedPts = [touches allObjects];
    NSLog(@"tappedPts= %@\n",tappedPts);
    
    for (int i = 0; i < tappedPts.count; i++) {
        
        CGPoint tappedPt = [[tappedPts objectAtIndex:i] locationInView:self];
        int     xPos = tappedPt.x;
        int     yPos = tappedPt.y;
        NSNumber *index = self.pointDict[[NSString stringWithFormat:@"%d, %d", xPos, yPos]];
        if (index != nil) {
            NSLog(@" In line %@\n",index);

            AVAudioPlayer *ap = (AVAudioPlayer *)self.avSounds[[index intValue]];
            [ap play];
        }
        
    }

   // NSLog(@"x:%d y:%d\n",xPos, yPos);
    
}

- (void) drawLines:(NSArray *)lineData {
    [self.pointDict removeAllObjects];
    
    NSArray *wavelens = (NSArray *)lineData[0];
    size_t numLines = wavelens.count;

    
    for (size_t i = 0; i < numLines; i++) {
        UIBezierPath *bp = [UIBezierPath bezierPath];
        bp.lineWidth = 4;
        bp.lineCapStyle = kCGLineCapRound;
        
        
        NSArray *line = (NSArray *)lineData[1][i];
        size_t lineLen = line.count;
        /*
         NSArray *firstCoord = (NSArray *)line[0];
         CGPoint firstPoint = CGPointMake((CGFloat)firstCoord[0], (CGFloat)firstCoord[1]));
         */
        CGPoint firstPoint = CGPointMake([line[0][1] floatValue], [line[0][0] floatValue]);
        //we don't add the first point to the dictionary. sad
        
        [bp moveToPoint:firstPoint];
        CGPoint prev = firstPoint;
        for (size_t j = 1; j < lineLen; j += 1) {
            CGPoint p = CGPointMake([line[j][1] floatValue], [line[j][0] floatValue]);
            [bp addLineToPoint:p];
            [bp moveToPoint:p];
            
          //  NSLog(@"adding to dict: %@\n",[NSValue valueWithCGPoint:p]);
            [self.pointDict setObject:[NSNumber numberWithUnsignedLong:i] forKey:[NSString stringWithFormat: @"%d, %d", (int) p.x, (int) p.y]];
            [self addInBetween:prev end:p forLine:i];
            
            prev = p;
                }
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"linesound%d", [wavelens[i] intValue]]
                                                  withExtension:@"WAV"];
        

        [self.avSounds addObject: [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil]];
        [bp stroke];
    }
    
 //   NSLog(@"dict: %@\n", self.pointDict);
}

-(void) addInBetween: (CGPoint)p1 end: (CGPoint)p2 forLine: (size_t) i{
    int x1 = p1.x;
    int y1 = p1.y;
    int x2 = p2.x;
    int y2 = p2.y;
    
    int dy = y2 - y1;
    int dx = x2 - x1;
    int stepx, stepy;
    
    if (dy < 0) { dy = -dy;  stepy = -1; } else { stepy = 1; }
    if (dx < 0) { dx = -dx;  stepx = -1; } else { stepx = 1; }
    dy <<= 1;        // dy is now 2*dy
    dx <<= 1;        // dx is now 2*dx
    
    [self.pointDict setObject:[NSNumber numberWithUnsignedLong:i] forKey:[NSString stringWithFormat: @"%d, %d", x1, y1]];
    
    if (dx > dy)
    {
        int fraction = dy - (dx >> 1);  // same as 2*dy - dx
        while (x1 != x2)
        {
            if (fraction >= 0)
            {
                y1 += stepy;
                fraction -= dx;          // same as fraction -= 2*dx
            }
            x1 += stepx;
            fraction += dy;              // same as fraction -= 2*dy
            [self.pointDict setObject:[NSNumber numberWithUnsignedLong:i] forKey:[NSString stringWithFormat: @"%d, %d", x1, y1]];
        }
    } else {
        int fraction = dx - (dy >> 1);
        while (y1 != y2) {
            if (fraction >= 0) {
                x1 += stepx;
                fraction -= dy;
            }
            y1 += stepy;
            fraction += dx;
            [self.pointDict setObject:[NSNumber numberWithUnsignedLong:i] forKey:[NSString stringWithFormat: @"%d, %d", x1, y1]];
        }
    }
    
    
}




@end

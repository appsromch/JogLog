//
//  PauseShape.m
//  SoundCompass
//
//  Created by Matthew Ragonese on 9/5/13.
//  Copyright (c) 2013 sharif ahmed. All rights reserved.
//

#import "PlayPauseShape.h"

@implementation PlayPauseShape

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //Make sure background color is correct
        self.backgroundColor = [UIColor clearColor];
        
        drawingForFirstTime = YES;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    if(drawingForFirstTime) {
        
        [self clearCurrentShape];
        [self createPlayShape];
        drawingForFirstTime = NO;
    }
    
    [lineColor setStroke];
    [fillColor setFill];
    
    [aPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    [aPath fillWithBlendMode:kCGBlendModeSourceOut alpha:0.8];
    
    [bPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    [bPath fillWithBlendMode:kCGBlendModeSourceOut alpha:0.8];
    
}

-(void)showPlayImage
{
    [self clearCurrentShape];
    
    [self createPlayShape];
}

-(void)showPauseImage
{
    [self clearCurrentShape];
    
    [self createPauseShape];
}

-(void)clearCurrentShape
{
    aPath = nil;
    bPath = nil;
    lineColor = nil;
    fillColor = nil;
    
    [self setNeedsDisplay];
}

-(void)createPauseShape
{
    //Make sure background color is correct
    self.backgroundColor = [UIColor clearColor];
    
    //Format path and color
    aPath = [UIBezierPath bezierPath];
    [aPath setLineJoinStyle:kCGLineJoinMiter];
    [aPath setLineWidth:3.0];
    bPath = [UIBezierPath bezierPath];
    [bPath setLineJoinStyle:kCGLineJoinMiter];
    [bPath setLineWidth:3.0];
    
    //fillColor = [UIColor colorWithRed:0.1647 green:0 blue:0.4824 alpha:1.0];
    fillColor = [UIColor whiteColor];
    lineColor = [UIColor whiteColor];
    
    //Constants
    int xMargin = (int)(self.frame.size.width/9.0);
    int yMargin = (int)(self.frame.size.height/7.0);
    int pauseLineWidth = (int)((self.frame.size.width-(5*xMargin))/2.0);
    int pauseLineHeight = (int)(self.frame.size.height-(2*yMargin));
    
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(2*xMargin,yMargin)];
    // Draw the lines.
    [aPath addLineToPoint:CGPointMake(2*xMargin+pauseLineWidth, yMargin)];
    [aPath addLineToPoint:CGPointMake(2*xMargin+pauseLineWidth, yMargin+pauseLineHeight)];
    [aPath addLineToPoint:CGPointMake(2*xMargin, yMargin+pauseLineHeight)];
    [aPath closePath];
    
    // Set the starting point of the shape.
    [bPath moveToPoint:CGPointMake(2*xMargin+pauseLineWidth+xMargin, yMargin)];
    // Draw the lines.
    [bPath addLineToPoint:CGPointMake(2*xMargin+2*pauseLineWidth+xMargin, yMargin)];
    [bPath addLineToPoint:CGPointMake(2*xMargin+2*pauseLineWidth+xMargin, yMargin+pauseLineHeight)];
    [bPath addLineToPoint:CGPointMake(2*xMargin+pauseLineWidth+xMargin, yMargin+pauseLineHeight)];
    [bPath closePath];

    //Redraw the shape
    //[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    if(!drawingForFirstTime) {
        [self setNeedsDisplay];
    }
}

-(void)createPlayShape
{
    //Format path and color
    aPath = [UIBezierPath bezierPath];
    [aPath setLineJoinStyle:kCGLineJoinMiter];
    //fillColor = [UIColor colorWithRed:0.1647 green:0 blue:0.4824 alpha:1.0];
    fillColor = [UIColor whiteColor];
    lineColor = [UIColor whiteColor];
    [aPath setLineWidth:3.0];
    
    //Constants
    int xMargin = (int)(self.frame.size.width/7.0);
    int yMargin = (int)(self.frame.size.height/5.0);
    
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(xMargin,yMargin)];
    
    // Draw the lines.
    [aPath addLineToPoint:CGPointMake(self.frame.size.width-xMargin, (int)(self.frame.size.height/2.0))];
    [aPath addLineToPoint:CGPointMake(xMargin, self.frame.size.height-yMargin)];
    [aPath closePath];
    
    //Redraw the shape
    //[self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    if(!drawingForFirstTime) {
        [self setNeedsDisplay];
    }
}

@end

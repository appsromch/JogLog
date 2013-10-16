//
//  NextShape.m
//  SoundCompass
//
//  Created by Matthew Ragonese on 9/5/13.
//  Copyright (c) 2013 sharif ahmed. All rights reserved.
//

#import "NextShape.h"

@implementation NextShape

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //Make sure background color is correct
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [self createNextShape];
    
    [lineColor setStroke];
    [fillColor setFill];
    
    [bPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    [bPath fillWithBlendMode:kCGBlendModeSourceOut alpha:0.9];
    
    [aPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    [aPath fillWithBlendMode:kCGBlendModeSourceOut alpha:0.9];
}

-(void)createNextShape
{
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
    int xMargin = (int)(self.frame.size.width/10.0);
    int yMargin = (int)(self.frame.size.height/5.0);
    
    // Set the starting point of the shape.
    [aPath moveToPoint:CGPointMake(xMargin,yMargin)];
    // Draw the lines.
    [aPath addLineToPoint:CGPointMake((int)self.frame.size.width/2.0, (int)self.frame.size.height/2.0)];
    [aPath addLineToPoint:CGPointMake(xMargin, self.frame.size.height-yMargin)];
    [aPath closePath];
    
    // Set the starting point of the shape.
    [bPath moveToPoint:CGPointMake((int)self.frame.size.width/2.0, yMargin)];
    // Draw the lines.
    [bPath addLineToPoint:CGPointMake(self.frame.size.width-xMargin, (int)(self.frame.size.height/2.0))];
    [bPath addLineToPoint:CGPointMake((int)self.frame.size.width/2.0, self.frame.size.height-yMargin)];
    [bPath closePath];
}

@end

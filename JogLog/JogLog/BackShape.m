//
//  BackShape.m
//  JogLog
//
//  Created by Matthew Ragonese on 10/15/13.
//  Copyright (c) 2013 Matthew Ragonese. All rights reserved.
//

#import "BackShape.h"

@implementation BackShape

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
    [self createBackShape];
    
    [lineColor setStroke];
    [fillColor setFill];
    
    [aPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    [aPath fillWithBlendMode:kCGBlendModeSourceOut alpha:0.9];
    
    [bPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    [bPath fillWithBlendMode:kCGBlendModeSourceOut alpha:0.9];
}

-(void)createBackShape
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
    [aPath moveToPoint:CGPointMake((int)self.frame.size.width/2.0, yMargin)];
    // Draw the lines.
    [aPath addLineToPoint:CGPointMake(xMargin, (int)self.frame.size.height/2.0)];
    [aPath addLineToPoint:CGPointMake((int)self.frame.size.width/2.0, self.frame.size.height-yMargin)];
    [aPath closePath];
    
    // Set the starting point of the shape.
    [bPath moveToPoint:CGPointMake((int)self.frame.size.width-xMargin, yMargin)];
    // Draw the lines.
    [bPath addLineToPoint:CGPointMake((int)(self.frame.size.width/2.0), (int)(self.frame.size.height/2.0))];
    [bPath addLineToPoint:CGPointMake((int)self.frame.size.width-xMargin, self.frame.size.height-yMargin)];
    [bPath closePath];
}

@end

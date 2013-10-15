//
//  Run.m
//  RunRagoneseRun
//
//  Created by Matthew Ragonese on 5/1/13.
//  Copyright (c) 2013 Matthew Ragonese. All rights reserved.
//

#import "Run.h"

@implementation Run

@synthesize totalDistance;
@synthesize totalTime;
//@synthesize averagePace;
@synthesize totalDistanceString;
@synthesize totalTimeString;
@synthesize averagePaceString;

-(id)initWithTotalTime:(int)time
         TotalDistance:(float)distance
{
    self = [super init];
    
    if(self) {
        
        [self setTotalDistance:distance];
        [self setTotalTime:time];
        
        [self setTotalDistanceString:[NSString stringWithFormat:@"%.2f mile", distance]];
        
        //For time
        uint seconds = fabs(time);
        uint minutes = seconds / 60;
        uint hours = minutes / 60;
        
        seconds -= minutes * 60;
        minutes -= hours * 60;
        
        [self setTotalTimeString:[NSString stringWithFormat:@"%@%02u:%02u:%02u", (time<0?@"-":@""), hours, minutes, seconds]];
        
        //For pace        
        if(time == 0 || distance == 0) {
            [self setAveragePaceString:@"0.00 mins/mile"];
        } else {
            float seconds = fabs(time);
            float minutes = seconds/60.0;
            float pace = minutes/distance;
            [self setAveragePaceString:[NSString stringWithFormat:@"%.2f mins/mile", pace]];
        }
    }
    
    return self;
}

@end

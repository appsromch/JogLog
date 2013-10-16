//
//  CustomCell.m
//  RunRagoneseRun
//
//  Created by Matthew Ragonese on 5/2/13.
//  Copyright (c) 2013 Matthew Ragonese. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.origin.x += 3;
    imageViewFrame.origin.y += 3;
    imageViewFrame.size.width -= 6;
    imageViewFrame.size.height -= 6;
    [[self imageView] setFrame:imageViewFrame];
    [[self imageView] setBackgroundColor:[UIColor lightGrayColor]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

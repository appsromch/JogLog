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
    imageViewFrame.origin.x += 5;
    imageViewFrame.origin.y += 5;
    imageViewFrame.size.width -= 10;
    imageViewFrame.size.height -= 10;
    [[self imageView] setFrame:imageViewFrame];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

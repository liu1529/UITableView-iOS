//
//  TableViewCell.m
//  TableView
//
//  Created by lxl on 14-9-30.
//  Copyright (c) 2014年 lxl. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    [super didTransitionToState:state];
    if (state == UITableViewCellStateDefaultMask) {
        self.textField.enabled = NO;

    }
    else  {
        self.textField.enabled = YES;
    }
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

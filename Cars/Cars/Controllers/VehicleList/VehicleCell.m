//
//  VehicleCell.m
//  Cars
//
//  Created by Sasi M on 26/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

#import "VehicleCell.h"

@implementation VehicleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:225.0/255.0 alpha:1.0];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end

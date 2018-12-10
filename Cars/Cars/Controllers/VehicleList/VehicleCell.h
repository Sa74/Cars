//
//  VehicleCell.h
//  Cars
//
//  Created by Sasi M on 26/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VehicleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *vehicleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

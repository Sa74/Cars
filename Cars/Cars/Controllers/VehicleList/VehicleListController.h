//
//  VehicleListController.h
//  Cars
//
//  Created by Sasi M on 26/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VehicleViewModel;

@interface VehicleListController : UIViewController

@property (weak, nonatomic) VehicleViewModel *vehicleViewModel;

- (void) reloadData;
- (void) resetVehicleSelection;

@end

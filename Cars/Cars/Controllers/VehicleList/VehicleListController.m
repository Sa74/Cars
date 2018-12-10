//
//  VehicleListController.m
//  Cars
//
//  Created by Sasi M on 26/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

#import "VehicleListController.h"
#import "VehicleCell.h"
#import "Cars-Swift.h"

@interface VehicleListController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UITableView *vehicleTableView;
@property (weak, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation VehicleListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationLabel.text = @"Hamburg, Germany";
    self.locationLabel.layer.masksToBounds = YES;
    self.locationLabel.layer.cornerRadius = 10.0;
    self.locationLabel.backgroundColor = [UIColor colorWithWhite:230.0/255.0 alpha:1.0];
    
    self.vehicleTableView.hidden = YES;
}

- (void) reloadData {
    self.vehicleTableView.hidden = NO;
    self.selectedIndexPath = nil;
    [self.vehicleTableView reloadData];
}

- (void) resetVehicleSelection {
    [self.vehicleTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    [self reloadData];
}

#pragma mark - TableView data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.vehicleViewModel getNumberOfVehicles];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* const CELL_IDENTIFIER = @"VehicleCell";
    VehicleCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    VehicleCellModel *vehicle = [self.vehicleViewModel getVehicleCellModelAt:indexPath];
    cell.vehicleImageView.image = vehicle.vehicleImage;
    cell.titleLabel.text = [NSString stringWithFormat:@"%lld",vehicle.vehicleId];
    cell.descriptionLabel.text = [NSString stringWithFormat:@"%@ - %@", vehicle.titleText, vehicle.descText];
    
    return cell;
}

#pragma mark - TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath == indexPath) {
        cell.backgroundColor = [UIColor colorWithWhite:225.0/255.0 alpha:0.75];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.vehicleViewModel.canSelectVehicle == YES) {
        self.selectedIndexPath = indexPath;
        [tableView reloadData];
        VehicleCellModel *vehicle = [self.vehicleViewModel getVehicleCellModelAt:indexPath];
        [self.vehicleViewModel selectVehicleWithId:vehicle.vehicleId];
    }
}

@end

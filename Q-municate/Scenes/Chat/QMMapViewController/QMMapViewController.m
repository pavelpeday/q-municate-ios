//
//  QMMapViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 09.06.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMMapViewController.h"
#import <MapKit/MapKit.h>

@interface QMMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation QMMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

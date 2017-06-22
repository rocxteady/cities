//
//  CityDetailViewController.m
//  Cities
//
//  Created by Ulaş Sancak on 22/06/2017.
//  Copyright © 2017 Ulaş Sancak. All rights reserved.
//

#import "CityDetailViewController.h"
#import <MapKit/MapKit.h>
#import "CityAnnotation.h"

static NSString *ReuseIdentifier = @"CityAnnotation";

@interface CityDetailViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *cityMapView;
@end

@implementation CityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadCity];
}

- (void)loadCity {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([_cityDictionary[@"coord"][@"lat"] floatValue], [_cityDictionary[@"coord"][@"lat"] floatValue]);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(7.0, 7.0));
    [_cityMapView setRegion:region animated:YES];
    CityAnnotation *annotation = [[CityAnnotation alloc] initWithCoordinate:coordinate title:_cityDictionary[@"name"] subtitle:_cityDictionary[@"country"]];
    [_cityMapView addAnnotation:annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ReuseIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ReuseIdentifier];
    }
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    [_cityMapView selectAnnotation:_cityMapView.annotations.firstObject animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  ViewController.m
//  SCMap
//
//  Created by admin on 2018/11/5.
//  Copyright © 2018 admin. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController ()<CLLocationManagerDelegate, MKMapViewDelegate>

//地理编码
@property (weak, nonatomic) IBOutlet UITextField *geoAddress;
@property (weak, nonatomic) IBOutlet UITextField *geoLongitude;
@property (weak, nonatomic) IBOutlet UITextField *geoLatitude;
@property (weak, nonatomic) IBOutlet UITextField *geoDetailAddress;

//反地理编码
@property (weak, nonatomic) IBOutlet UITextField *reverseGeoLongitude;
@property (weak, nonatomic) IBOutlet UITextField *reverseGeoLatitude;
@property (weak, nonatomic) IBOutlet UITextField *reverseGeoAddress;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self checkLocationPermission];

    [self setupMapView];
}

- (void)setupMapView {
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mapView.delegate = self;
    mapView.mapType = MKMapTypeStandard;
    mapView.userTrackingMode = MKUserTrackingModeFollow;
    mapView.showsUserLocation = YES;//默认YES，自带蓝色光圈大头针
    mapView.showsCompass = YES;
    mapView.userLocation.title = @"SC";
//    mapView.userLocation.subtitle = @"map";
    [self.view addSubview:mapView];

    //蓝色光圈大头针
//    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
//    pointAnnotation.coordinate = self.mapView.region.center;
////    pointAnnotation.title = @"Title";
////    pointAnnotation.subtitle = @"Subtitle";
//    [self.mapView addAnnotation:pointAnnotation];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //MKPinAnnotationView 是 MKAnnotationView 的子类
    //系统自带大头针
//    static NSString *pin = @"pin";
//    MKPinAnnotationView *pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pin];
//    pinAnnotationView.pinTintColor = [UIColor blackColor];
//    pinAnnotationView.animatesDrop = YES;
//    return pinAnnotationView;

    //静态图片大头针
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *map = @"map";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:map];
    if (annotationView == nil) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:map];
        annotationView.image = [UIImage imageNamed:@"map"];
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;

        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        leftView.backgroundColor = [UIColor orangeColor];
        rightView.backgroundColor = [UIColor greenColor];
        annotationView.leftCalloutAccessoryView = leftView;
        annotationView.rightCalloutAccessoryView = rightView;
    }
    return annotationView;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations firstObject];
    NSLog(@"经度：%f, 纬度：%f, 水平精确度：%f, 垂直精确度：%f", location.coordinate.longitude, location.coordinate.latitude, location.horizontalAccuracy, location.verticalAccuracy);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败");
}

- (void)checkLocationPermission {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:{
            [self requestLocation];
            NSLog(@"Not Determined");
            break;
        }
        case kCLAuthorizationStatusRestricted:{
            NSLog(@"Restricted");
            break;
        }
        case kCLAuthorizationStatusDenied:{
            NSLog(@"Denied");
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            [self requestLocation];
            NSLog(@"Always");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            [self requestLocation];
            NSLog(@"When In Use");
            break;
        }
        default:
            break;
    }
}

- (void)requestLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - 地理编码
- (IBAction)geoAction:(id)sender {
    NSString *address = self.geoAddress.text;
    if (self.geoAddress.text.length == 0) {
        return;
    }

    [self.geoCoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            NSLog(@"没有找到你要的地址");
        } else {
            for (CLPlacemark *placeMark in placemarks) {
                NSLog(@"name: %@, locality: %@, country: %@", placeMark.name, placeMark.locality, placeMark.country);
            }
            CLPlacemark *firstPlaceMark = [placemarks firstObject];

            CLLocationDegrees longitude = firstPlaceMark.location.coordinate.longitude;
            CLLocationDegrees latitude = firstPlaceMark.location.coordinate.latitude;

            self.geoLongitude.text = [NSString stringWithFormat:@"%f", longitude];
            self.geoLatitude.text = [NSString stringWithFormat:@"%f", latitude];
            self.geoDetailAddress.text = [NSString stringWithFormat:@"%@ %@", firstPlaceMark.country, firstPlaceMark.locality];
        }
    }];
}

#pragma mark - 反地理编码
- (IBAction)reverseGeoAction:(id)sender {
    NSString *longitudeText = self.reverseGeoLongitude.text;
    NSString *latitudeText = self.reverseGeoLatitude.text;

    if (longitudeText.length == 0 || latitudeText.length == 0) {
        return;
    }

    CLLocationDegrees longitude = [longitudeText doubleValue];
    CLLocationDegrees latitude = [latitudeText doubleValue];

    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            NSLog(@"没有找到你要的地址");
        } else {
            CLPlacemark *firstPlaceMark = [placemarks firstObject];
            self.reverseGeoAddress.text = [NSString stringWithFormat:@"%@ %@ %@", firstPlaceMark.country, firstPlaceMark.locality, firstPlaceMark.name];
        }
    }];
}

#pragma mark - lazy load
- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//设置精确度
    }
    return _locationManager;
}

- (CLGeocoder *)geoCoder {
    if (_geoCoder == nil) {
        _geoCoder = [[CLGeocoder alloc] init];
    }
    return _geoCoder;
}


@end

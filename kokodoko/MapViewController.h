//
//  ViewController.h
//  kokodoko
//
//  Created by EATis on 2013/10/28.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "Location.h"

#import "NADView.h"

#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController : UIViewController<CLLocationManagerDelegate,GMSMapViewDelegate,UIAlertViewDelegate,NADViewDelegate>{
    // CLLocationManager
    //__strong CLLocationManager *_locationManager;
    BOOL firstLocationUpdate_;
    
    NADView* nadView;
}

@property(nonatomic,retain) NADView* nadView;

@property (assign, nonatomic) float latitudeCode;
@property (assign, nonatomic) float longitudeCode;

@property (assign, nonatomic) BOOL isReachability;

// CLLocationManager
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) GMSMarker *marker;
@property (strong, nonatomic) GMSCameraPosition *camera;

@property (strong, nonatomic) Reachability *curReach;

@property (weak, nonatomic) IBOutlet UIButton *kokodokoBtn;
@property (weak, nonatomic) IBOutlet UIView *mapPanelView;

- (void)kokodoko:(id)sender;

- (void)initCameraLocation;
- (void)initGoogleMap;
- (void)showAlartView;

-(void)notifiedNetworkStatus:(NSNotification *)notification;

@end

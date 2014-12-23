//
//  ViewController.m
//  kokodoko
//
//  Created by EATis on 2013/10/28.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import "MapViewController.h"
#import "Post.h"
#import "ImakokoViewController.h"

#import "UIButton+Bootstrap.h"

#import <UIActivityIndicatorView+AFNetworking.h>
#import <UIAlertView+AFNetworking.h>

#import <CRGradientNavigationBar.h>

#define NAD_VIEW_SIZE CGSizeMake(320, 50)

@interface MapViewController ()
@property (nonatomic, retain) CLGeocoder *geocoder;
@property (nonatomic, retain) NSMutableArray *addressesArray;

@property (readwrite, nonatomic, strong) NSArray *posts;

@end

@implementation MapViewController

@synthesize nadView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.navigationBar.barTintColor    = [UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor    = [UIColor whiteColor];
    //self.navigationController.navigationBar.alpha        = 1.0f;
    self.navigationController.navigationBar.translucent  = YES;
    
    [_mapPanelView.layer setCornerRadius:5];
    [_mapPanelView setClipsToBounds:YES];
        
    [self.kokodokoBtn warningStyle];
    [self.kokodokoBtn addAwesomeIcon:FAIconSearch beforeTitle:YES];

    //_locationManager = [[CLLocationManager alloc] init];
    //_locationManager.delegate = self;
    
    // ジオコーディングのインスタンス生成
    _geocoder = [[CLGeocoder alloc] init];
    // 履歴を保持する配列
    _addressesArray = [[NSMutableArray alloc] init];
    
    
    Reachability *myCurReach = [Reachability reachabilityForInternetConnection];
    _curReach = myCurReach;
    NetworkStatus networkStatus = [_curReach currentReachabilityStatus];
    
    switch (networkStatus) {
        case NotReachable:  //圏外
            /*圏外のときの処理*/
            NSLog(@"圏外");
            _kokodokoBtn.enabled = NO;
            _isReachability = NO;
            [self initCameraLocation];
            [self showAlartView];
            break;
        case ReachableViaWWAN:  //3G
            /*3G回線接続のときの処理*/
            _kokodokoBtn.enabled = YES;
            _isReachability = YES;
            break;
        case ReachableViaWiFi:  //WiFi
            /*WiFi回線接続のときの処理*/
            _kokodokoBtn.enabled = YES;
            _isReachability = YES;
            break;
        default:
            /*上記以外*/
            _kokodokoBtn.enabled = NO;
            _isReachability = NO;
            [self initCameraLocation];
            [self showAlartView];
            break;
    }
    
    // 続いて、NSNotificationCenterに、
    // ネットワーク状態が変化した際に通知を受ける対象を指定します。
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notifiedNetworkStatus:)
     name:kReachabilityChangedNotification
     object:nil];
    
    // ネットワーク監視を開始します。
    [_curReach startNotifier];
    
    
    [self initGoogleMap];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kokodoko.png"]];
    
    
    //==============================================
    //        NADViewの設定　start
    //==============================================
    // Frameを指定してNADViewを生成
    self.nadView = [[NADView alloc] init];
    [self.nadView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    
    // nendSDKログ出力の設定(任意)
    [self.nadView setIsOutputLog:YES];
    
    // 広告枠のapikey/spotidを設定します(必須)
    [self.nadView setNendID:@"" spotID:@""];
    
    // delegateを受けるオブジェクトを指定(必須)
    [self.nadView setDelegate:self];
    
    // 背景色を指定(任意)
    [self.nadView setBackgroundColor:[UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1]];
    
    // 読み込み開始(必須)
    [self.nadView load:[NSDictionary dictionaryWithObjectsAndKeys:@"3600", @"retry", nil]];
    // 通知有無にかかわらずViewに乗せる場合
    //[self.view addSubview:self.nadView];
    //==============================================
    //        NADViewの設定　end
    //==============================================

}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:18];
        
        
        _latitudeCode = self.mapView.camera.target.latitude;
        _longitudeCode = self.mapView.camera.target.longitude;

        NSLog(@"lat:%f lon:%f",location.coordinate.latitude, location.coordinate.longitude);
    }
}


#pragma mark - KVO updates
- (void)initGoogleMap
{    
    
    // Creates a marker in the center of the map.
    /*
    GMSMarker *myMarker = [[GMSMarker alloc] init];
    self.marker = myMarker;
    self.marker.position = CLLocationCoordinate2DMake(35.681382, 139.766084);
    self.marker.title = @"Sydney";
    self.marker.snippet = @"Australia";
    self.marker.map = self.mapView;
    self.marker.draggable = YES;
    */
    //self.marker.icon
    
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    
    
    // Listen to the myLocation property of GMSMapView.
    
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
    
    self.mapView.delegate = self;
    
}


#pragma mark - self delegate :ロケーションマネージャー作成
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // ロケーションマネージャーを作成
	self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
		self.locationManager.delegate = self;
		// 位置情報取得開始
		//[self.locationManager startUpdatingLocation];
	}else{
        NSLog(@"位置情報使えないよ><");
    }
    
    
    /**
     * nand ad
     */
    // 再開
    [self.nadView resume];
    
    // 注意：他アプリ起動から、自アプリが復帰した際に広告のリフレッシュを再開するには
    // AppDelegate applicationDidEnterBackground などを利用してください
    
    // 広告位置設定例
    // １．画面上部に広告を表示させる場合
    //[self.nadView setFrame:CGRectMake((self.view.frame.size.width - NAD_VIEW_SIZE.width) /2, 0, NAD_VIEW_SIZE.width, NAD_VIEW_SIZE.height)];
    // ２．画面下部に広告を表示させる場合
    [self.nadView setFrame:CGRectMake((self.view.frame.size.width - NAD_VIEW_SIZE.width) /2, self.view.frame.size.height - NAD_VIEW_SIZE.height, NAD_VIEW_SIZE.width, NAD_VIEW_SIZE.height)];
    /**
     * nand ad
     */

}

// この画面が隠れたら、広告のリフレッシュを中断します
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"ViewController viewWillDisappear");
    
    // 中断
    [self.nadView pause];
    
    // 注意：safariなど他アプリが起動し自分自身が背後に回った際に広告のリフレッシュを中止するには
    // AppDelegate applicationDidEnterBackground などを利用してください
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ここどこボタンを押したときの処理
- (void)kokodoko:(id)sender {
    NSLog(@"start updating location. timestamp:%@", [[NSDate date] description]);
}


#pragma mark - ios api のgeogenaratorlat,lonを取得
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // もっとも最近の位置情報を得る
    CLLocation *recentLocation = locations.lastObject;
    
    
    _latitudeCode = recentLocation.coordinate.latitude;
    _longitudeCode = recentLocation.coordinate.longitude;
    
    
    NSLog(@"location:%f %f timestamp:%@", _latitudeCode, _longitudeCode, recentLocation.timestamp.description);
    
    //[self.locationManager stopUpdatingLocation];  // 何回もこのメソッドが呼ばれたくないならこのメソッドを追加する
}

// 位置情報が取得失敗した場合にコールされる。
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if (error) {
        
		NSString* message = nil;
		switch ([error code]) {
                // アプリでの位置情報サービスが許可されていない場合
			case kCLErrorDenied:
				// 位置情報取得停止
				[self.locationManager stopUpdatingLocation];
				message = [NSString stringWithFormat:@"このアプリは位置情報サービスが許可されていません。"];
				break;
			default:
				message = [NSString stringWithFormat:@"位置情報の取得に失敗しました。"];
                
                [self initCameraLocation];
                
				break;
		}
		if (message) {
			// アラートを表示
			UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}
}


#pragma mark - google maps sdk delegate
/**
 * 地図の表示領域（カメラ）が変更された際に通知される。
 * アニメーション中は途中の表示領域が通知されたない場合があるが、最終的な位置で通知される。
 */
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    
    _latitudeCode = position.target.latitude;
    _longitudeCode = position.target.longitude;

    //NSLog(@"didChangeCameraPosition %f,%f", position.target.latitude, position.target.longitude);
    NSLog(@"didChangeCameraPosition %f,%f", _latitudeCode, _longitudeCode);
}


#pragma mark - 値渡し
- (void)initCameraLocation
{
    //東京駅 緯度：35.681382 経度：139.766084
    GMSCameraPosition *myCamera = [GMSCameraPosition cameraWithLatitude:35.681382
                                                              longitude:139.766084
                                                                   zoom:14];
    self.camera = myCamera;
    self.mapView.camera = self.camera;
    self.mapView.myLocationEnabled = YES;
    
    _latitudeCode = [self.camera targetAsCoordinate].latitude;
    _longitudeCode = [self.camera targetAsCoordinate].longitude;
    
    NSLog(@"%f %f",[self.camera targetAsCoordinate].latitude,[self.camera targetAsCoordinate].longitude);
}

#pragma mark - 値渡し
- (void)prepareForSegue:(UIStoryboardSegue *) segue sender:(id) sender {
    if ([[segue identifier] isEqualToString:@"imakokoVCSegue"]) {
        
        
        
        ImakokoViewController *imakokoVC = segue.destinationViewController;
        
        [self.locationManager stopUpdatingLocation];  // 何回もこのメソッドが呼ばれたくないならこのメソッドを追加する
        
        [self kokodoko:Nil];
        
        imakokoVC.latitude = _latitudeCode;
        imakokoVC.longitude = _longitudeCode;
        
        //NSLog(@"prepare lat:%f lon:%f",[self.camera targetAsCoordinate].latitude, [self.camera targetAsCoordinate].longitude);
        NSLog(@"prepare lat:%f lon:%f",_latitudeCode, _longitudeCode);
        
        
        //imakokoVC.latitude = 35.005203;
        //imakokoVC.longitude = 135.940475;
        
    }
    
}

#pragma mark - alart view 関連
- (void)showAlartView
{
    //アラートビューの生成と設定
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"圏外"
                          message:@"ネットワークに繋がっていません"
                          delegate:self
                          cancelButtonTitle:@"OK！" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - alart view 関連
// 通知を受け取るメソッド
-(void)notifiedNetworkStatus:(NSNotification *)notification {
    NSLog(@"notification");
    // reachability変数から、現在のネットワーク状態を取得します。
    NetworkStatus networkStatus = [_curReach currentReachabilityStatus];
    
    // 受け取ったネットワーク状態に合わせて、処理を行います。
    // 下記例の場合、wifiか3Gの状態になった場合には、startWorkを呼び出し、
    // 圏外になったら、stopWorkを呼び出しています。

    
    switch (networkStatus) {
        case NotReachable:  //圏外
            /*圏外のときの処理*/
            _kokodokoBtn.enabled = NO;
            _isReachability = NO;
            [self showAlartView];
            break;
        case ReachableViaWWAN:  //3G
            /*3G回線接続のときの処理*/
            _kokodokoBtn.enabled = YES;
            _isReachability = YES;
            break;
        case ReachableViaWiFi:  //WiFi
            /*WiFi回線接続のときの処理*/
            _kokodokoBtn.enabled = YES;
            _isReachability = YES;
            break;
        default:
            /*上記以外*/
            _kokodokoBtn.enabled = NO;
            _isReachability = NO;
            [self showAlartView];
            break;
    }
    
}


#pragma mark - NADViewDelegate
// 広告の受信に成功し表示できた場合に１度通知されます。必須メソッドです。
-(void)nadViewDidFinishLoad:(NADView *)adView {
    
    // 広告の受信と表示の成功が通知されてからViewを乗せる場合はnadViewDidFinishLoadを利用します。
    [self.view addSubview:self.nadView];
    
    NSLog(@"NADViewDelegate nadViewDidFinishLoad");
}


// 以下は広告受信成功ごとに通知される任意メソッドです。
-(void)nadViewDidReceiveAd:(NADView *)adView {
    // Success.
    NSLog(@"NADViewDelegate nadViewDidReceiveAd");
}

// 以下は広告受信失敗ごとに通知される任意メソッドです。
-(void)nadViewDidFailToReceiveAd:(NADView *)adView{
    // Error.
    NSLog(@"NADViewDelegate nadViewDidFailToReceiveAd");
    
    // エラー発生時の情報をログに出力します
    NSError* nadError = adView.error;
    // エラーコード
    NSLog(@"code = %ld", (long)nadError.code);
    // エラーメッセージ
    NSLog(@"message = %@", nadError.domain);
}

// 以下はバナー広告がクリックされるごとに通知される任意メソッドです。
-(void)nadViewDidClickAd:(NADView *)adView {
    // Banner clicked.
    NSLog(@"NADViewDelegate nadViewDidClickAd");
}

// ------------------------------------------------------------------------------------------------
// リリース
// ------------------------------------------------------------------------------------------------
#pragma mark - life cycle
-(void)dealloc {
    // delegateには必ずnilセットして解放する
    [self.nadView setDelegate:nil];
    self.nadView = nil;
    
    NSLog(@"ViewController ...dealloc");
}



@end

//
//  ImakokoViewController.m
//  kokodoko
//
//  Created by EATis on 2013/10/30.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import "ImakokoViewController.h"
#import "Location.h"

#import <UIActivityIndicatorView+AFNetworking.h>
#import <UIAlertView+AFNetworking.h>

#import <MRProgressOverlayView.h>

#import <CRGradientNavigationBar.h>

#define NAD_VIEW_SIZE CGSizeMake(320, 50)

@interface ImakokoViewController ()
@property (nonatomic, retain) CLGeocoder *geocoder;
@property (nonatomic, retain) NSMutableArray *addressesArray;

@property (readwrite, nonatomic, strong) NSArray *posts;

@property (strong, nonatomic) NSMutableArray *choices_;
@end

@implementation ImakokoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // ジオコーディングのインスタンス生成
    _geocoder = [[CLGeocoder alloc] init];
    // 履歴を保持する配列
    _addressesArray = [[NSMutableArray alloc] init];
    
    NSLog(@"lat:%f lon:%f",_latitude, _longitude);
    
    //show progress view
    [self displayProgressView];
    
    //[self convertToAddress:Nil];
    [self httpRequestWithAddress];
    
    
    // UIPickerViewに表示する内容
    //_choices_ = @[@"ゆうちょ銀行本店渋谷駅南口出張所", @"February", @"March", @"April", @"May", @"June", @"July",@"August", @"September", @"October", @"November", @"December"];
    
    
    NSMutableArray *newMutableArr = [@[@"選択しない",@"ここ来て",@"ここにいる",@"ここに集合"] mutableCopy];
    _choices_ = newMutableArr;
    _sendText = @"ここ";
    _contentTextField.text = _sendText;
    
    //UIPickerView *pickerView = [[UIPickerView alloc] init];
    //_addressPickerView = pickerView;
    // delegate,dataSource設定
    _addressPickerView.delegate = self;
    _addressPickerView.dataSource = self;
    // 選択状態のインジケーターを表示（デフォルト：NO）
    _addressPickerView.showsSelectionIndicator = YES;
    // コンポーネント0の指定行を選択状態にする（初期選択状態の設定）
    //[_addressPickerView selectRow:7 inComponent:0 animated:NO];
    
    
    //ジェスチャー登録
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    self.singleTap.delegate = self;
    self.singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:self.singleTap];
    
    
    [_panelView.layer setCornerRadius:5];
    [_panelView setClipsToBounds:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"test sizeToFit");
    [_addressLabel sizeToFit];
    [_locationLabel sizeToFit];
    
    
    
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

#pragma mark - UIPickerViewDataSource
-(void)onSingleTap:(UITapGestureRecognizer *)recognizer {
    [self.contentTextField resignFirstResponder];
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.singleTap) {
        // キーボード表示中のみ有効
        if (self.contentTextField.isFirstResponder) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark - UIPickerViewDataSource

// コンポーネント数（列数）
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// 行数
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return [_choices_ count];
}

#pragma mark - UIPickerViewDelegate

// 表示内容
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_choices_ objectAtIndex:row];
}

// 選択時（くるくる回して止まった時に呼ばれる）
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _locationLabel.text = [_choices_ objectAtIndex:row];
    if (row == 0) {
        _sendText = @"ここ";
    } else {
        _sendText =[_choices_ objectAtIndex:row];
    }
    
    _contentTextField.text = _sendText;
    
    NSLog(@"selected: %@", [_choices_ objectAtIndex:row]);
}

// 標準の文字サイズだと犬種／猫種の名称が表示しきれないため、フォントを小さく設定する
- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *retval = (id)view;
    if (!retval) {
        retval= [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
        retval.textAlignment = NSTextAlignmentCenter;
    }
    //retval.text = _choices_[row];
    retval.text = [_choices_ objectAtIndex:row];
    
    // フォントサイズを設定する
    if ([retval.text length] > 20) {
        retval.font = [UIFont systemFontOfSize:13];
    }
    else if ([retval.text length] > 16) {
        retval.font = [UIFont systemFontOfSize:14];
    }
    else if ([retval.text length] > 12) {
        retval.font = [UIFont systemFontOfSize:15];
    }
    else {
        retval.font = [UIFont systemFontOfSize:15];
    }
    
    return retval;
}


#pragma mark - lineで送るmethod
- (IBAction)sendWithLine:(id)sender {
    
    //NSString *sendText = [NSString stringWithFormat:@"いまここ（%@）",_shortenURL];
    NSString *sendText = [NSString stringWithFormat:@"%@（%@）",_sendText ,_shortenURL];
    NSString *plainString = sendText;
    
    // escape
    NSString *contentKey = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                        NULL,
                                                                                        (CFStringRef)plainString,
                                                                                        NULL,
                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                        kCFStringEncodingUTF8 );
    
    NSString *contentType = @"text";
    
    // LINE のサイトに遷移して、アプリが入っている場合はラインにリダイレクトする方法。
    //NSString *urlString = [NSString stringWithFormat: @"http://line.naver.jp/R/msg/%@/?%@", contentType, contentKey];
    //NSString *urlString = [NSString stringWithFormat: @"line://msg/text/%@", sendText];
    //NSURL *url = [NSURL URLWithString:urlString];
    
    
    BOOL isInstalled = (BOOL)[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://"]];
    
    // LINE に直接遷移。contentType で画像を指定する事もできる。アプリが入っていない場合は何も起きない。
    
    if (!isInstalled) {
        [[[UIAlertView alloc] initWithTitle:@"Line is not installed." message:@"Please download Line from App Store, and try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        NSString *urlString2 = [NSString
                                stringWithFormat:@"line://msg/%@/%@",
                                contentType, contentKey];
        NSURL *url = [NSURL URLWithString:urlString2];
        
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (IBAction)sendWithMail:(id)sender {
    [self sendEmailWithLocation:_shortenURL];
}

- (IBAction)sendWithMessage:(id)sender {
    [self sendMessageWithLocation:_shortenURL];
}


#pragma mark - ios api の geogenerator lat,lonを住所に変更
- (void)convertToAddress:(id)sender {
    // 緯度・経度が正しいかをチェック
     if (![self coordinateIsValid]) {
     return;  // エラーがあれば変換しない
     }
    
    // 入力されている緯度・経度を元にCLLocationを作成
    CLLocationDegrees latitude = _latitude;
    CLLocationDegrees longitude = _longitude;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    NSLog(@"latitude:%f longitude:%f",latitude, longitude);
    
    // 逆ジオコーディングの開始
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%s | %@", __PRETTY_FUNCTION__, error);
            [_addressesArray insertObject:[self errorToString:error] atIndex:0];  // 最新のものを先頭に
        } else {
            if (0 < [placemarks count]) {
                // ログ出力
                NSLog(@"%s", __PRETTY_FUNCTION__);
                CLPlacemark *p = [placemarks objectAtIndex:0];
                [self logPlacemark:p];
                // 住所のテキストフィールドに反映
                NSString *formattedAddress = [[p.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "];
                
                NSString *state = [p.addressDictionary objectForKey:@"State"];
                NSString *locality = [p.addressDictionary objectForKey:@"City"];
                NSString *name = [p.addressDictionary objectForKey:@"Name"];
                
                NSString *stateAddress = [NSString stringWithFormat:@"%@ %@\n%@",state,locality,name];
                
                NSLog(@"state address:%@",stateAddress);
                
                _address = formattedAddress;
                _addressLabel.text = stateAddress;
                
                [self setLabelHeight];
                
                //short url を取得
                [self getShortUrl];
                // ログに残す
                [_addressesArray insertObject:formattedAddress atIndex:0];  // 最新のものを先頭に
            }
        }
    }];
    
}



#pragma mark - http request
- (void)httpRequestWithLocation
{
    // 緯度・経度が正しいかをチェック
    if (![self coordinateIsValid]) {
        return;  // エラーがあれば変換しない
    }
    
    // 入力されている緯度・経度を元にCLLocationを作成
    CLLocationDegrees latitude = _latitude;
    CLLocationDegrees longitude = _longitude;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    //[location coordinate].latitude
    NSLog(@"%f %f",[location coordinate].latitude,[location coordinate].longitude);
    
    NSURLSessionTask *task = [Post locationCode:location withProgressView:_progressView globalTimelinePostsWithBlock:^(NSArray *posts, NSError *error) {
        
        if (!error) {
            self.posts = posts;
            _post = [self.posts objectAtIndex:0];
            
            _address = @"";
            
            for (NSDictionary *state in _post.location) {
                //self.address = [_address stringByAppendingString:[NSString stringWithFormat:@"%@ ",state]];
                self.address = [_address stringByAppendingFormat:@"%@",state];
                //self.address = [_address stringByAppendingString:@"test"];
                NSLog(@"state:%@",state);
            }
            
            _addressLabel.text = _address;
            NSLog(@"state:%@",_address);
            
            //short url を取得
            //[self getShortUrl];
            
            
            NSMutableArray *newMutableArr = [NSMutableArray new];
            
            newMutableArr = [NSMutableArray arrayWithCapacity:[_post.locationdata count]];
            NSLog(@"count:%d",[_post.locationdata count]);
            [newMutableArr addObject:@"選択しない"];
            for (Location *location in _post.locationdata) {
                
                //newMutableArr = [@[location.locationName] mutableCopy];
                [newMutableArr addObject:location.locationName];
                NSLog(@"location:%@",location.locationName);
            }
            
            _choices_ = newMutableArr;
            
            [_addressPickerView reloadAllComponents];
            //[_addressPickerView selectRow:7 inComponent:0 animated:NO];
            
            _locationLabel.text = [_choices_ objectAtIndex:0];
            
            NSLog(@"%@",_choices_);
            
            
            //labeleの高さを調節
            [self setLabelHeight];
        } else {
            
            /*
            MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
            progressView.mode = MRProgressOverlayViewModeCross;
            progressView.titleLabelText = @"Failed";
            [self performBlock:^{
                [progressView dismiss:YES];
            } afterDelay:2.0];
            */
        }
        
    }];
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)self.navigationItem.leftBarButtonItem.customView;
    [activityIndicatorView setAnimatingWithStateOfTask:task];
}


#pragma mark - http request
- (void)httpRequestWithAddress
{
    // 緯度・経度が正しいかをチェック
    if (![self coordinateIsValid]) {
        return;  // エラーがあれば変換しない
    }
    
    // 入力されている緯度・経度を元にCLLocationを作成
    CLLocationDegrees latitude = _latitude;
    CLLocationDegrees longitude = _longitude;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    //[location coordinate].latitude
    NSLog(@"%f %f",[location coordinate].latitude,[location coordinate].longitude);
    
    NSURLSessionTask *task = [Post locationCode:location withProgressView:_progressView globalTimelinePostsWithBlock:^(NSArray *posts, NSError *error) {
        
        if (!error) {
            self.posts = posts;
            _post = [self.posts objectAtIndex:0];
            
            
            for (NSDictionary *add in _post.address) {
                //self.address = [_address stringByAppendingString:[NSString stringWithFormat:@"%@ ",state]];
                self.address = [NSString stringWithFormat:@"%@", add];
                //self.address = [_address stringByAppendingString:@"test"];
            }
            
            _addressLabel.text = _address;
            NSLog(@"state:%@",_address);
            
            
            _locationLabel.text = [_choices_ objectAtIndex:0];
            
            //short url を取得
            [self getShortUrl];
            
            //labeleの高さを調節
            [self setLabelHeight];
        } else {
            
            
             MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
             progressView.mode = MRProgressOverlayViewModeCross;
             progressView.titleLabelText = @"Failed";
             [self performBlock:^{
             [progressView dismiss:YES];
             } afterDelay:2.0];
             
        }
        
    }];
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)self.navigationItem.leftBarButtonItem.customView;
    [activityIndicatorView setAnimatingWithStateOfTask:task];
}


#pragma mark - 位置情報を表示しているラベルの高さを設定
- (void)setLabelHeight
{
    [_addressLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_addressLabel setNumberOfLines:0];
    CGRect frame = [_addressLabel frame];
    frame.size = CGSizeMake(_addressLabel.frame.size.width, 5000);
    [_addressLabel setFrame:frame];
    [_addressLabel sizeToFit];
    
    [_locationLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_locationLabel setNumberOfLines:0];
    CGRect locationframe = [_locationLabel frame];
    locationframe.size = CGSizeMake(_locationLabel.frame.size.width, 5000);
    [_locationLabel setFrame:locationframe];
    [_locationLabel sizeToFit];
}

#pragma mark - input validation methods
/* 入力されている値が、正しい緯度・経度であるかを判定
 * CLLocationCoordinate2DIsValid だと、緯度か経度のどちらが誤っているかを検知できない
 */
- (BOOL)coordinateIsValid
{
    NSString *coordinateRangeString = @"^[+-]?\\d+(?:\\.\\d+)?$";
    BOOL latitudeIsValid = YES;
    BOOL longitudeIsValid = YES;
    NSRange range;
    
    /* 緯度が正しいかをチェック */
    range = [[NSString stringWithFormat:@"%f",_latitude] rangeOfString:coordinateRangeString options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        latitudeIsValid = NO;  // 緯度ではない
    } else {
        // 範囲内の数値であるか
        CLLocationDegrees latitude = [[NSString stringWithFormat:@"%f",_latitude] floatValue];
        if (latitude < -90 || 90 < latitude) {
            latitudeIsValid = NO;  // 緯度ではない
        }
    }
    // Viewに反映
    if (latitudeIsValid) {
        //_latitudeLabel.textColor = [UIColor blackColor];
    } else {
        //_latitudeLabel.textColor = [UIColor redColor];
    }
    
    /* 経度が正しいかをチェック */
    range = [[NSString stringWithFormat:@"%f",_latitude] rangeOfString:coordinateRangeString options:NSRegularExpressionSearch];
    if (range.location == NSNotFound) {
        longitudeIsValid = NO;  // 経度ではない
    } else {
        // 範囲内の数値であるか
        CLLocationDegrees longitude = [[NSString stringWithFormat:@"%f",_latitude] floatValue];
        if (longitude < -180 || 180 < longitude) {
            longitudeIsValid = NO;  // 経度ではない
        }
    }
    // Viewに反映
    if (longitudeIsValid) {
        //_longitudeLabel.textColor = [UIColor blackColor];
    } else {
        //_longitudeLabel.textColor = [UIColor redColor];
    }
    
    // 緯度・経度の両方が正しい場合のみYES
    return (latitudeIsValid && longitudeIsValid);
}


#pragma mark - private methods

/* エラーを文字列に変換 */
- (NSString *)errorToString:(NSError *)error
{
    switch ([error code]) {
        case kCLErrorGeocodeFoundNoResult:
            return @"NoResult";
        case kCLErrorGeocodeFoundPartialResult:
            return @"PartialResult";
        case kCLErrorGeocodeCanceled:
            return @"Canceled";
        default:
            return [error localizedDescription];
    }
}

/* プレースマークの情報をログに残すだけ */
- (void)logPlacemark:(CLPlacemark *)placemark
{
    NSLog(@"addressDictionary: %@", placemark.addressDictionary);
    NSLog(@"administrativeArea: %@", placemark.administrativeArea);
    NSLog(@"areasOfInterest: %@", placemark.areasOfInterest);
    NSLog(@"country: %@", placemark.country);
    NSLog(@"inlandWater: %@", placemark.inlandWater);
    NSLog(@"locality: %@", placemark.locality);
    NSLog(@"name: %@", placemark.name);
    NSLog(@"ocean: %@", placemark.ocean);
    NSLog(@"postalCode: %@", placemark.postalCode);
    NSLog(@"region: %@", placemark.region);
    NSLog(@"subAdministrativeArea: %@", placemark.subAdministrativeArea);
    NSLog(@"subLocality: %@", placemark.subLocality);
    NSLog(@"subThoroughfare: %@", placemark.subThoroughfare);
    NSLog(@"thoroughfare: %@", placemark.thoroughfare);
}


#pragma mark - get short url
- (void)getShortUrl
{
    //https://maps.google.co.jp/maps?q=%83%89%83t%83H%81%5b%83%8c%8c%b4%8fh&z=18&t=m
    
    NSString *baseURLString = @"https://maps.google.co.jp/maps?z=18&t=m&q=%@";
    
    NSString *escapedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self.address,/*@"エンコード前の文字列"*/ NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    
    NSString *urlString = [NSString stringWithFormat:baseURLString, escapedString];
    
    UrlShortener *shortener = [[UrlShortener alloc] initWithDelegate:self];
    [shortener shortenUrl:urlString/*@"短くしたいURL"*/ withService:UrlShortenerServiceGoogle];
}

- (void)urlShortenerSucceededWithShortUrl:(NSString *)shortUrl {
    _shortenURL = shortUrl;
    NSLog(@"shortUrl:%@",_shortenURL);
}

- (void)urlShortenerFailedWithError:(NSError *)error {
    // Handle the error.
    NSLog(@"Error: %@", [error localizedDescription]);
}


#pragma mark - send email 関係
- (void)sendEmailWithLocation:(NSString *)shortenUrl
{
	MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject:@"今いる場所"];
    [mailViewController setMessageBody:[NSString stringWithFormat:@"%@（%@）",_sendText ,shortenUrl] isHTML:NO];
	mailViewController.mailComposeDelegate = self;
	
    [self.navigationController presentViewController:mailViewController animated:YES completion:nil];
	
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
	
	NSString *mailError = nil;
	switch (result) {
		case MFMailComposeResultSent:
            break;
		case MFMailComposeResultFailed:
            mailError = @"メールの送信に失敗しました";
			break;
		default:
			break;
	}
	
	if (mailError != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mailError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
	
}


#pragma mark - send message 関係
- (void)sendMessageWithLocation:(NSString *)shortenUrl
{
	MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
	[messageViewController setSubject:@"今いる場所"];
	   
    [messageViewController setBody:[NSString stringWithFormat:@"%@（%@）",_sendText ,shortenUrl]];
    
    messageViewController.messageComposeDelegate = self;
    
	
    [self.navigationController presentViewController:messageViewController animated:YES completion:nil];
	
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
	
	NSString *mailError = nil;
	switch (result) {
		case MessageComposeResultSent:
            break;
		case MessageComposeResultFailed:
            mailError = @"Messageの送信に失敗しました";
			break;
		default:
			break;
	}
	
	if (mailError != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mailError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}

}

#pragma mark - MRProgressView ...
- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

- (void)displayProgressView
{
    // Block only the navigation controller
    MRProgressOverlayView *myProgressView = [MRProgressOverlayView new];
    _progressView = myProgressView;
    _progressView.mode = MRProgressOverlayViewModeIndeterminateSmall;
    [self.navigationController.view addSubview:_progressView];
    [_progressView show:YES];
    [self performBlock:^{
        //[_progressView dismiss:YES];
    } afterDelay:2.0];

}


@end

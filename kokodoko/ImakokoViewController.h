//
//  ImakokoViewController.h
//  kokodoko
//
//  Created by EATis on 2013/10/30.
//  Copyright (c) 2013年 EATis. All rights reserved.
//

#import "MapViewController.h"

#import "NADView.h"

#import "Post.h"
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "UrlShortener.h"

#import <MRProgress.h>
#import <MRProgress/MRProgress.h>


@interface ImakokoViewController : MapViewController<CLLocationManagerDelegate,UrlShortenerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate, UIGestureRecognizerDelegate,NADViewDelegate>


@property (assign, nonatomic) float latitude;
@property (assign, nonatomic) float longitude;

@property (weak, nonatomic) NSString *sendText;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *shortenURL;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *addressPickerView;

@property(nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@property (weak, nonatomic) IBOutlet UIView *panelView;

@property (nonatomic, strong) Post *post;

@property (strong, nonatomic) MRProgressOverlayView *progressView;

- (IBAction)sendWithLine:(id)sender;

- (IBAction)sendWithMail:(id)sender;

- (IBAction)sendWithMessage:(id)sender;

- (void)convertToAddress:(id)sender;
- (void)httpRequestWithLocation;
- (void)httpRequestWithAddress;
- (void)getShortUrl;
- (void)sendEmailWithLocation:(NSString *)shortenUrl;
- (void)sendMessageWithLocation:(NSString *)shortenUrl;

- (void)displayProgressView;

@end

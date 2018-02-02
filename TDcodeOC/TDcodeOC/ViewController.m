//
//  ViewController.m
//  TDcodeOC
//
//  Created by 塞班客 on 2018/2/2.
//  Copyright © 2018年 cey. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
static const float lightWidth = 240.f;
static const float lightHeight = 240.f;
static const float crossLineWidth = 2.f;
static const float crossLineHeight = 15.f;
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    float leftWith;
    float topHeight;
}
@property (strong , nonatomic ) AVCaptureDevice *captureDevice;
@property (strong , nonatomic ) AVCaptureDeviceInput *captureInput;
@property (strong , nonatomic ) AVCaptureMetadataOutput *captureOutput;
@property (strong , nonatomic ) AVCaptureSession *captureSession;
@property (strong , nonatomic ) AVCaptureVideoPreviewLayer *capturePreview;

@property (strong,nonatomic) UIButton *flashLightBtn;
@property (strong,nonatomic) UIImageView *lineImageView;

@end

@implementation ViewController
@synthesize captureDevice = _captureDevice;
@synthesize captureInput = _captureInput;
@synthesize captureOutput = _captureOutput;
@synthesize capturePreview = _capturePreview;
@synthesize captureSession = _captureSession;
//@synthesize delegate = _delegate;
//@synthesize isRectScan = _isRectScan;
@synthesize lineImageView = _lineImageView;
@synthesize flashLightBtn = _flashLightBtn;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"扫一扫";
    CGRect screenRect = [UIScreen mainScreen].bounds;
    leftWith = (screenRect.size.width - lightWidth) / 2;
    topHeight =(screenRect.size.height - lightHeight) / 2-50;
//    [self initScanCode];
    [self initLayer];
    [self initViewControl];
  
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initScanCode];
    [self scanLineAnimation];
//    self.tabBarController.tabBar.hidden = YES;
//    [self.navigationController setNavigationBarHidden:NO];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
-(void)viewWillDisappear:(BOOL)animated {
    [self stopScanCode];
    [super viewWillDisappear:animated];
}
- (void)willResignActiveNotification {
    _flashLightBtn.selected = NO;
}
- (void)didBecomeActiveNotification {
    
}
//加载界面上的控件，如：加上闪光灯按钮等
- (void)initViewControl {
    @autoreleasepool {
        _flashLightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashLightBtn setImage:[UIImage imageNamed:@"OpenFlashLight.png"] forState:UIControlStateNormal];
        [_flashLightBtn setImage:[UIImage imageNamed:@"CloseFlashLight.png"] forState:UIControlStateSelected];
        _flashLightBtn.frame = CGRectMake(leftWith, 80.f, 30.f, 30.f);
        [_flashLightBtn addTarget:self action:@selector(systemFlashLight) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_flashLightBtn];
        
        _lineImageView = [[UIImageView alloc] initWithImage:nil];
        _lineImageView.backgroundColor = [UIColor greenColor];
        _lineImageView.frame = CGRectMake(leftWith, topHeight, lightWidth, 2);
        [self.view addSubview:_lineImageView];
        [self scanLineAnimation];
    }
    
}

- (void)scanLineAnimation {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:4.f];
    //设置代理
    [UIView setAnimationDelegate:self];
    //设置动画执行完毕调用的事件
    [UIView setAnimationDidStopSelector:@selector(didViewAnimation)];
    _lineImageView.frame = CGRectMake(leftWith,topHeight + lightHeight-2,lightWidth,2);
    [UIView commitAnimations];
    
}

-(void)didViewAnimation {
    //  self.navigationController
    _lineImageView.frame = CGRectMake(leftWith, topHeight, lightWidth, 2);
    [self scanLineAnimation];
}

- (void)insertLayerWithFrame:(CGRect)frame withBackgroundColor:(UIColor *)backgroundColor {
    @autoreleasepool {
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = backgroundColor.CGColor;
        layer.frame = frame;
        [self.view.layer addSublayer:layer];
    }
}
//初始化layer层，绘制半透明区域
-(void) initLayer {
    //公共参数
    UIColor *fillColor = [UIColor colorWithRed:0xae/255.f green:0xae/255.f blue:0xae/255.f alpha:0.4];
    UIColor *crossColor = [UIColor greenColor];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    //填充色，左边
    [self insertLayerWithFrame:CGRectMake(0, 0, leftWith, screenRect.size.height) withBackgroundColor:fillColor];
    //上面
    [self insertLayerWithFrame:CGRectMake(leftWith, 0, lightWidth, topHeight) withBackgroundColor:fillColor];
     //右面
    [self insertLayerWithFrame:CGRectMake(leftWith + lightWidth, 0, leftWith, screenRect.size.height) withBackgroundColor:fillColor];
     //下面
    [self insertLayerWithFrame:CGRectMake(leftWith, topHeight + lightHeight, lightWidth, screenRect.size.height-(topHeight + lightHeight)) withBackgroundColor:fillColor];
    //线条
    [self insertLayerWithFrame:CGRectMake(leftWith, topHeight, crossLineWidth, crossLineHeight) withBackgroundColor:crossColor];
    //线条
    [self insertLayerWithFrame:CGRectMake(leftWith, topHeight, crossLineHeight, crossLineWidth) withBackgroundColor:crossColor];
    //线条
    [self insertLayerWithFrame:CGRectMake(leftWith + lightWidth - crossLineHeight, topHeight, crossLineHeight, crossLineWidth) withBackgroundColor:crossColor];
    //线条
    [self insertLayerWithFrame:CGRectMake(leftWith + lightWidth - crossLineWidth, topHeight, crossLineWidth, crossLineHeight) withBackgroundColor:crossColor];
    //线条
    [self insertLayerWithFrame:CGRectMake(leftWith, topHeight + lightHeight - crossLineHeight, crossLineWidth, crossLineHeight) withBackgroundColor:crossColor];
    //线条
    [self insertLayerWithFrame:CGRectMake(leftWith, topHeight + lightHeight - crossLineWidth, crossLineHeight, crossLineWidth) withBackgroundColor:crossColor];
    //线条
    [self insertLayerWithFrame:CGRectMake(leftWith + lightWidth - crossLineHeight, topHeight + lightHeight - crossLineWidth, crossLineHeight, crossLineWidth) withBackgroundColor:crossColor];
    //线条
    [self insertLayerWithFrame:CGRectMake(leftWith + lightWidth - crossLineWidth, topHeight + lightHeight - crossLineHeight, crossLineWidth, crossLineHeight) withBackgroundColor:crossColor];
}

-(void)initScanCode {
    @autoreleasepool {
        _captureDevice = [ AVCaptureDevice defaultDeviceWithMediaType : AVMediaTypeVideo];
        _captureInput = [ AVCaptureDeviceInput deviceInputWithDevice : _captureDevice error : nil ];
        _captureOutput = [[ AVCaptureMetadataOutput alloc ] init ];
        [_captureOutput setMetadataObjectsDelegate : self queue : dispatch_get_main_queue ()];
        //        if (_isRectScan) {
        //            CGRect screenRect = [UIScreen mainScreen].bounds;
        //            [ _captureOutput setRectOfInterest : CGRectMake (topHeight / screenRect.size.height, leftWith / screenRect.size.width, lightHeight/screenRect.size.height, lightWidth / screenRect.size.width)];
        //        }
        
        _captureSession = [[ AVCaptureSession alloc ] init ];
        [_captureSession setSessionPreset : AVCaptureSessionPresetHigh ];
        if ([_captureSession canAddInput : _captureInput ])
        {
            [_captureSession addInput : _captureInput ];
        }
        if ([_captureSession canAddOutput : _captureOutput ])
        {
            [_captureSession addOutput : _captureOutput ];
        }
        _captureOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode ] ;
        
        _capturePreview =[ AVCaptureVideoPreviewLayer layerWithSession :_captureSession ];
        _capturePreview.videoGravity = AVLayerVideoGravityResizeAspectFill ;
        _capturePreview.frame = self.view.layer.bounds ;
        [self.view.layer insertSublayer : _capturePreview atIndex : 0 ];
        [_captureSession startRunning ];
    }
}

- ( void )captureOutput:( AVCaptureOutput *)captureOutput didOutputMetadataObjects:( NSArray *)metadataObjects fromConnection:( AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *scanCodeResult;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            //            [self stopScanCode];
            scanCodeResult = metadataObj.stringValue;
            //回调信息
            NSLog(@"%@",scanCodeResult);
            
            //            if (_delegate && [_delegate respondsToSelector:@selector(scanCodeResultByViewController:withScanCodeResult:)]) {
            //                [_delegate scanCodeResultByViewController:self withScanCodeResult:scanCodeResult];
            //                [self.navigationController popViewControllerAnimated:YES];
            //            }
        } else {
            NSLog(@"扫描信息错误！");
        }
    }
}

- (void)systemFlashLight
{
#if !TARGET_IPHONE_SIMULATOR
    if([_captureDevice hasTorch] && [self.captureDevice hasFlash])
    {
        [_captureSession beginConfiguration];
        [_captureDevice lockForConfiguration:nil];
        if(_captureDevice.torchMode == AVCaptureTorchModeOff)
        {
            _flashLightBtn.selected = YES;
            [_captureDevice setTorchMode:AVCaptureTorchModeOn];
            [_captureDevice setFlashMode:AVCaptureFlashModeOn];
        }
        else {
            _flashLightBtn.selected = NO;
            [_captureDevice setTorchMode:AVCaptureTorchModeOff];
            [_captureDevice setFlashMode:AVCaptureFlashModeOff];
        }
        [_captureDevice unlockForConfiguration];
        [_captureSession commitConfiguration];
    }
#else
    [CommonUtil showAlert:G_ALERTTITLE withMessage:@"虚拟设备不能运行摄像头！"];
#endif
}

-(void)stopScanCode {
    [_captureSession stopRunning];
    _captureSession = nil;
    _captureDevice = nil;
    _captureInput = nil;
    _captureOutput = nil;
    [_capturePreview removeFromSuperlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/**
 * @author 半  饱, 15-12-18
 *
 * @brief 生成二维码图片
 *
 * @param code  生成二维码图片内容
 * @param width 二维码图片宽度
 * @param height 二维码图片高度
 *
 * @return 返回UIImage对象
 */
- (UIImage *)generateQRCode:(NSString *)code width:(CGFloat)width height:(CGFloat)height {
    CIImage *qrcodeImage;
    NSData *data = [code dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:false];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    qrcodeImage = [filter outputImage];
    
    CGFloat scaleX = width / qrcodeImage.extent.size.width;
    CGFloat scaleY = height / qrcodeImage.extent.size.height;
    CIImage *transformedImage = [qrcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
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


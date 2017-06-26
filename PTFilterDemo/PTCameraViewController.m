//
//  PTCameraViewController.m
//  PTFilterDemo
//
//  Created by CHEN KAIDI on 19/5/2016.
//  Copyright © 2016 Putao. All rights reserved.
//

#import "PTCameraViewController.h"
#import "PTFilterTableViewCell.h"
#import "GPUImage.h"
#import "PTFilterManager.h"
#define kCellHeight 80
#define kDefaultSaturation 1.0
#define kDefaultBrightness 0.0
#define kDefaultExposure 0.0
#define kDefaultRGB 1.0
#define kDefaultWhiteBalance 7500.0
#define kDefaultSepia 0.0

@interface PTCameraViewController ()<UITableViewDelegate, UITableViewDataSource>{
    BOOL filterMenuOn;
}
@property (nonatomic, strong) NSMutableArray *filterSettings;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GPUImageView *cameraFilterPreview;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *cameraFilterInput;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *cameraFilterOutput;
@property (strong, nonatomic) GPUImageVideoCamera *camera;
@property (nonatomic, strong) UIButton *filterMenuButton;
@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *flipCamera;
@property (nonatomic, assign) UIImagePickerControllerCameraDevice cameraPosition;
@end

static NSString *PTFilterTableViewCellID = @"PTFilterTableViewCellID";
@implementation PTCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    filterMenuOn = NO;
    [self.view addSubview:self.cameraFilterPreview];
    [self.camera addTarget:self.cameraFilterInput];
    
    [self.view addSubview:self.dismissButton];
    [self.view addSubview:self.flipCamera];
    [self.view addSubview:self.filterMenuButton];
    [self.view addSubview:self.tableView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.tableView addGestureRecognizer:tapGesture];
    self.filterMenuButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-self.filterMenuButton.frame.size.height/2-20);
    // Do any additional setup after loading the view.
    {
        GPUImageSaturationFilter *filter = [[GPUImageSaturationFilter alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:filter, @"filter",@"Saturation（饱和度）", @"name",[NSNumber numberWithFloat:0.0],@"min",[NSNumber numberWithFloat:2.0],@"max", [NSNumber numberWithFloat:kDefaultSaturation],@"current",nil];
        [self.filterSettings addObject:dict];
    }
    {
        GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:filter, @"filter",@"Brightness（亮度）", @"name",[NSNumber numberWithFloat:-1.0],@"min",[NSNumber numberWithFloat:1.0],@"max", [NSNumber numberWithFloat:kDefaultBrightness],@"current",nil];
        [self.filterSettings addObject:dict];
    }
    {
        GPUImageExposureFilter *filter = [[GPUImageExposureFilter alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:filter, @"filter",@"Exposure（曝光度）", @"name",[NSNumber numberWithFloat:-4.0],@"min",[NSNumber numberWithFloat:4.0],@"max", [NSNumber numberWithFloat:kDefaultExposure],@"current",nil];
        [self.filterSettings addObject:dict];
    }
    {
        GPUImageRGBFilter *filter = [[GPUImageRGBFilter alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:filter, @"filter",@"RGB（三色平衡）", @"name",[NSNumber numberWithFloat:0.0],@"min",[NSNumber numberWithFloat:2.0],@"max", [NSNumber numberWithFloat:kDefaultRGB],@"current",nil];
        [self.filterSettings addObject:dict];
    }
    {
        GPUImageWhiteBalanceFilter *filter = [[GPUImageWhiteBalanceFilter alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:filter, @"filter",@"White Balance（冷色）", @"name",[NSNumber numberWithFloat:-2500.0],@"min",[NSNumber numberWithFloat:7500.0],@"max", [NSNumber numberWithFloat:kDefaultWhiteBalance],@"current",nil];
        [self.filterSettings addObject:dict];
    }
    {
        GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:filter, @"filter",@"Sepia Tone（暗褐色）", @"name",[NSNumber numberWithFloat:0.0],@"min",[NSNumber numberWithFloat:1.0],@"max", [NSNumber numberWithFloat:kDefaultSepia],@"current",nil];
        [self.filterSettings addObject:dict];
    }
    [self.tableView reloadData];
    [self updateFilterChain];
    [self.camera startCameraCapture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openFilter{
    filterMenuOn = YES;
    [self toggleFilterMenu];
}

-(void)closeFilter{
    filterMenuOn = NO;
    [self toggleFilterMenu];
}

-(void)changeCameraPosition{
    [self.camera rotateCamera];
}

-(void)cameraStillImageCapture{
    [self.cameraFilterOutput useNextFrameForImageCapture];
    UIImage *image = [self.cameraFilterOutput imageFromCurrentFramebuffer];
}

-(void)toggleFilterMenu{
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1
          initialSpringVelocity:0.6 options:UIViewAnimationOptionAllowUserInteraction  animations:^(){
              if (filterMenuOn) {
                  self.tableView.frame = CGRectMake(0, self.view.frame.size.height-kCellHeight*self.filterSettings.count, self.view.frame.size.width, kCellHeight*self.filterSettings.count);
                  self.filterMenuButton.center = CGPointMake(self.view.frame.size.width/2, self.tableView.frame.origin.y-self.filterMenuButton.frame.size.height/2-20);
                  self.filterMenuButton.alpha = 0.0;
              }else{
                  self.tableView.frame = CGRectMake(0, self.view.frame.size.height+kCellHeight*self.filterSettings.count, self.view.frame.size.width, kCellHeight*self.filterSettings.count);
                  self.filterMenuButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-self.filterMenuButton.frame.size.height/2-20);
                  self.filterMenuButton.alpha = 1.0;
              }
          } completion:^(BOOL finished) {
          }];
}

-(void)updateFilterChain{
    self.cameraFilterOutput = [PTFilterManager chainInput:self.cameraFilterInput settings:self.filterSettings beautify:YES];
    [self.cameraFilterOutput addTarget:self.cameraFilterPreview];
    
}

-(void)resetFilter{
    for(NSMutableDictionary *dict in self.filterSettings){
        if ([[dict objectForKey:@"name"] isEqualToString:@"Saturation（饱和度）"]) {
            [dict setObject:[NSNumber numberWithFloat:kDefaultSaturation] forKey:@"current"];
        }
        if ([[dict objectForKey:@"name"] isEqualToString:@"Brightness（亮度）"]) {
            [dict setObject:[NSNumber numberWithFloat:kDefaultBrightness] forKey:@"current"];
        }
        if ([[dict objectForKey:@"name"] isEqualToString:@"Exposure（曝光度）"]) {
            [dict setObject:[NSNumber numberWithFloat:kDefaultExposure] forKey:@"current"];
        }
        if ([[dict objectForKey:@"name"] isEqualToString:@"RGB（三色平衡）"]) {
            [dict setObject:[NSNumber numberWithFloat:kDefaultRGB] forKey:@"current"];
        }
        if ([[dict objectForKey:@"name"] isEqualToString:@"White Balance（冷色）"]) {
            [dict setObject:[NSNumber numberWithFloat:kDefaultWhiteBalance] forKey:@"current"];
        }
        if ([[dict objectForKey:@"name"] isEqualToString:@"Sepia Tone（暗褐色）"]) {
            [dict setObject:[NSNumber numberWithFloat:kDefaultSepia] forKey:@"current"];
        }
    }
    [self.cameraFilterInput removeAllTargets];
    [self updateFilterChain];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        // handling code
        [self resetFilter];
        [self.tableView reloadData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filterSettings.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PTFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PTFilterTableViewCellID forIndexPath:indexPath];
    NSDictionary *setting = [self.filterSettings objectAtIndex:indexPath.row];
    [cell setFilterSliderMin:[[setting objectForKey:@"min"] floatValue] max:[[setting objectForKey:@"max"] floatValue] current:[[setting objectForKey:@"current"] floatValue]];
    [cell setAttributeWithFilterName:[setting objectForKey:@"name"] filterIntensity:[[setting objectForKey:@"current"] floatValue]];
    cell.valueChanged = ^(NSString *name, CGFloat value){
        for(NSMutableDictionary *dict in self.filterSettings){
            if ([[dict objectForKey:@"name"] isEqualToString:name]) {
                [dict setObject:[NSNumber numberWithFloat:value] forKey:@"current"];
                NSLog(@"value:%f",value);
            }
        }
        [self.cameraFilterInput removeAllTargets];
        [self updateFilterChain];
    };
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSDictionary *dict = [self.filterSettings objectAtIndex:sourceIndexPath.row];
    [self.camera stopCameraCapture];
    [self.filterSettings removeObjectAtIndex:sourceIndexPath.row];
    [self.filterSettings insertObject:dict atIndex:destinationIndexPath.row];
    [self.cameraFilterInput removeAllTargets];
    [self updateFilterChain];
    [self.camera startCameraCapture];
}

-(NSMutableArray *)filterSettings{
    if (!_filterSettings) {
        _filterSettings = [[NSMutableArray alloc] init];
    }
    return _filterSettings;
}

-(GPUImageOutput <GPUImageInput>*) cameraFilterInput{
    if (!_cameraFilterInput) {
        _cameraFilterInput = [[GPUImageFilter alloc] init];
    }
    return _cameraFilterInput;
}

-(GPUImageView *)cameraFilterPreview{
    if (!_cameraFilterPreview) {
        _cameraFilterPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
        _cameraFilterPreview.center = self.view.center;
        _cameraFilterPreview.backgroundColor = [UIColor clearColor];
    }
    return _cameraFilterPreview;
}

-(GPUImageVideoCamera *)camera{
    if (!_camera) {
        _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
        _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _camera.horizontallyMirrorFrontFacingCamera = YES;
    }
    return _camera;
}

-(UIButton *)flipCamera{
    if (!_flipCamera) {
        _flipCamera = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 0, 60, 60)];
        [_flipCamera setImage:[UIImage imageNamed:@"icon_capture_20_14"] forState:UIControlStateNormal];
        [_flipCamera setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_flipCamera addTarget:self action:@selector(changeCameraPosition) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flipCamera;
}

-(UIButton *)dismissButton{
    if (!_dismissButton) {
        _dismissButton = [[UIButton alloc] initWithFrame:self.view.bounds];
        [_dismissButton addTarget:self action:@selector(closeFilter) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

-(UIButton *)filterMenuButton{
    if (!_filterMenuButton) {
        _filterMenuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [_filterMenuButton setTitle:@"滤镜" forState:UIControlStateNormal];
        _filterMenuButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [_filterMenuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _filterMenuButton.layer.cornerRadius = 40;
        _filterMenuButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _filterMenuButton.layer.borderWidth = 2.5;
        [_filterMenuButton addTarget:self action:@selector(openFilter) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterMenuButton;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height+kCellHeight*self.filterSettings.count, self.view.frame.size.width, kCellHeight*5) style:UITableViewStylePlain];
        _tableView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [_tableView registerClass:[PTFilterTableViewCell class] forCellReuseIdentifier:PTFilterTableViewCellID];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        [_tableView setEditing:YES animated:YES];
        _tableView.allowsSelection = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end

//
//  PTFilterManager.m
//  PTFilterDemo
//
//  Created by CHEN KAIDI on 19/5/2016.
//  Copyright © 2016 Putao. All rights reserved.
//

#import "PTFilterManager.h"

#define PTBilateralFilterDistance 30
#define PTUnsharpDensity 0.8

@implementation PTFilterManager

+(GPUImageOutput <GPUImageInput>*)beautifyFaceFilterWithInput:(GPUImageOutput *)input{
    // Preparing filters
    GPUImageBilateralFilter *filterA = [[GPUImageBilateralFilter alloc] init];
    ((GPUImageBilateralFilter *)filterA).distanceNormalizationFactor = PTBilateralFilterDistance;
    GPUImageUnsharpMaskFilter *filterB = [[GPUImageUnsharpMaskFilter alloc] init];
    filterB.intensity = PTUnsharpDensity;
    
    // Chain
    [input addTarget:filterA];
    [filterA addTarget:filterB];
    return filterB;
}


+(GPUImageOutput <GPUImageInput>*)chainInput:(GPUImageOutput *)input settings:(NSArray *)settings beautify:(BOOL)beautify{
    
    GPUImageOutput *baseOutput = nil;
    if (beautify) {
        baseOutput = [self beautifyFaceFilterWithInput:input];
    }else{
        baseOutput = input;
    }
    
    NSMutableArray *filterArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in settings){
        GPUImageOutput<GPUImageInput> *filter = [dict objectForKey:@"filter"];
        filter = [self setFilter:filter value:[[dict objectForKey:@"current"] floatValue]];
        [filterArray addObject:filter];
    }
    [baseOutput addTarget:filterArray[0]];
    for (int i=0; i<filterArray.count; i++) {
        if (i<filterArray.count-1) {
            [filterArray[i] addTarget:filterArray[i+1]];
        }
    }
    return filterArray[filterArray.count-1];
    
}

+(GPUImageOutput<GPUImageInput> *)setFilter:(GPUImageOutput<GPUImageInput> *)filter value:(CGFloat)value{
    if ([filter isKindOfClass:[GPUImageSaturationFilter class]]) {
        [(GPUImageSaturationFilter *)filter setSaturation:value];
    }
    if ([filter isKindOfClass:[GPUImageBrightnessFilter class]]) {
        [(GPUImageBrightnessFilter *)filter setBrightness:value];
    }
    if ([filter isKindOfClass:[GPUImageExposureFilter class]]) {
        [(GPUImageExposureFilter *)filter setExposure:value];
    }
    if ([filter isKindOfClass:[GPUImageRGBFilter class]]) {
        [(GPUImageRGBFilter *)filter setGreen:value];
    }
    if ([filter isKindOfClass:[GPUImageWhiteBalanceFilter class]]) {
        [(GPUImageWhiteBalanceFilter *)filter setTemperature:value];
    }
    if ([filter isKindOfClass:[GPUImageSepiaFilter class]]) {
        [(GPUImageSepiaFilter *)filter setIntensity:value];
    }
    return filter;
}

@end

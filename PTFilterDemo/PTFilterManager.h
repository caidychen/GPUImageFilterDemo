//
//  PTFilterManager.h
//  PTFilterDemo
//
//  Created by CHEN KAIDI on 19/5/2016.
//  Copyright © 2016 Putao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface PTFilterManager : NSObject

+(GPUImageOutput <GPUImageInput>*)chainInput:(GPUImageOutput *)input settings:(NSArray *)settings beautify:(BOOL)beautify;
@end

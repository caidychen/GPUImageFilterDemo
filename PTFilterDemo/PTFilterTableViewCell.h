//
//  PTFilterTableViewCell.h
//  PTFilterDemo
//
//  Created by CHEN KAIDI on 19/5/2016.
//  Copyright © 2016 Putao. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SliderValueChanged)(NSString *filterName, CGFloat value);
@interface PTFilterTableViewCell : UITableViewCell
@property (nonatomic, copy) SliderValueChanged valueChanged;
-(void)setFilterSliderMin:(CGFloat)min max:(CGFloat)max current:(CGFloat)current;
-(void)setAttributeWithFilterName:(NSString *)filterName filterIntensity:(CGFloat)filterIntensity;

@end

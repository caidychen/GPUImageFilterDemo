//
//  PTFilterTableViewCell.m
//  PTFilterDemo
//
//  Created by CHEN KAIDI on 19/5/2016.
//  Copyright © 2016 Putao. All rights reserved.
//

#import "PTFilterTableViewCell.h"


@interface PTFilterTableViewCell ()
@property (nonatomic, strong) UILabel *filterNameLabel;
@property (nonatomic, strong) UILabel *intensityLabel;
@property (nonatomic, strong) UISlider *slider;
@end

@implementation PTFilterTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.contentView addSubview:self.filterNameLabel];
        [self.contentView addSubview:self.intensityLabel];
        [self.contentView addSubview:self.slider];
        [self setFilterSliderMin:0 max:1 current:0.5];
        [self layoutSubviews];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.filterNameLabel.frame = CGRectMake(-30, 10, self.frame.size.width/2, self.filterNameLabel.font.lineHeight);
    self.intensityLabel.frame = CGRectMake(-30+self.frame.size.width/2, 10, self.frame.size.width/2-20, self.intensityLabel.font.lineHeight);
    self.slider.frame = CGRectMake(-15, self.filterNameLabel.font.lineHeight+10, self.frame.size.width-40, self.frame.size.height-self.filterNameLabel.font.lineHeight);
}

-(void)setFilterSliderMin:(CGFloat)min max:(CGFloat)max current:(CGFloat)current{
    [self.slider setMinimumValue:min];
    [self.slider setMaximumValue:max];
    [self.slider setValue:current];
}

-(void)setAttributeWithFilterName:(NSString *)filterName filterIntensity:(CGFloat)filterIntensity{
    self.filterNameLabel.text = filterName;
    self.intensityLabel.text = [NSString stringWithFormat:@"%.1f",filterIntensity];
}

-(void)sliderValueChanged{
    if (self.valueChanged) {
        self.valueChanged(self.filterNameLabel.text, self.slider.value);
    }
    self.intensityLabel.text = [NSString stringWithFormat:@"%.1f",self.slider.value];
}

-(UILabel *)filterNameLabel{
    if (!_filterNameLabel) {
        _filterNameLabel = [[UILabel alloc] init];
        _filterNameLabel.textColor = [UIColor whiteColor];
    }
    return _filterNameLabel;
}

-(UILabel *)intensityLabel{
    if (!_intensityLabel) {
        _intensityLabel = [[UILabel alloc] init];
        _intensityLabel.textAlignment = NSTextAlignmentRight;
        _intensityLabel.textColor = [UIColor whiteColor];
    }
    return _intensityLabel;
}

-(UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

@end

//
//  FBFuncationBottomView.m
//  multi_image_picker
//
//  Created by 杨志豪 on 4/26/22.
//

#import "FBFuncationBottomView.h"
#import "FBVideoCLipHeader.h"
#import "NSBundle+TZImagePicker.h"

@interface FBFuncationBottomView()

@property (weak, nonatomic) IBOutlet UIView *switchView;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end

@implementation FBFuncationBottomView


+ (FBFuncationBottomView *)showWithTitle:(NSString *)title{
    FBFuncationBottomView *view = [[NSBundle tz_imagePickerBundle] loadNibNamed:NSStringFromClass(FBFuncationBottomView.class) owner:self options:nil].firstObject;
    view.switchView.hidden = YES;
    view.titleLabel.text = title;
    return view;
}

+ (FBFuncationBottomView *)showWithTwoTitlesLeftTitle:(NSString *)left rightTitle:(NSString *)right{
    FBFuncationBottomView *view = [[NSBundle tz_imagePickerBundle] loadNibNamed:NSStringFromClass(FBFuncationBottomView.class) owner:self options:nil].firstObject;
    view.switchView.hidden = NO;
    view.titleLabel.hidden = YES;
    [view.leftButton setTitle:left forState:UIControlStateNormal];
    [view.leftButton setTitle:left forState:UIControlStateSelected];
    [view.rightButton setTitle:right forState:UIControlStateNormal];
    [view.rightButton setTitle:right forState:UIControlStateSelected];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)leftButtonAction:(id)sender {
    if (self.leftButton.isSelected) {
        return;
    }
    self.leftButton.selected = YES;
    self.rightButton.selected = NO;
    if (self.leftTitleAction) {
        self.leftTitleAction();
    }
}

- (IBAction)rightButtonAction:(id)sender {
    if (self.rightButton.isSelected) {
        return;
    }
    self.leftButton.selected = NO;
    self.rightButton.selected = YES;
    if (self.rightTitleAction) {
        self.rightTitleAction();
    }
}

- (IBAction)cancelButtonAction:(id)sender {
    if(self.cancelAction) {
        self.cancelAction();
    }
}

- (IBAction)doneButtonAction:(id)sender {
    if (self.sureAction) {
        self.sureAction();
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFuncatinBottomConfrimedNotifi" object:nil userInfo:nil];
}

-(void)upadteTitle:(NSString*)title{
    self.titleLabel.text = title;
}
@end

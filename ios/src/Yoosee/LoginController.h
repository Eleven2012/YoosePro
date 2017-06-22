

#import <UIKit/UIKit.h>
@class MBProgressHUD;
@interface LoginController : UIViewController

@property (strong, nonatomic) UIView *mainView1;
@property (strong, nonatomic) UIView *mainView2;
@property (strong, nonatomic) UITextField *usernameField1;
@property (strong, nonatomic) UITextField *passwrodField1;
@property (strong, nonatomic) UITextField *usernameField2;
@property (strong, nonatomic) UITextField *passwrodField2;

@property (strong, nonatomic) MBProgressHUD *progressAlert;


@property (strong,nonatomic) NSString *countryCode;
@property (strong,nonatomic) NSString *countryName;

@property (strong,nonatomic) UILabel *leftLabel;
@property (strong,nonatomic) UILabel *rightLabel;


@property (assign) NSInteger loginType;
@property (nonatomic) BOOL isSessionIdError;
@property (nonatomic) BOOL isP2PVerifyCodeError;

@property (strong,nonatomic) NSString *lastRegisterId;
@end

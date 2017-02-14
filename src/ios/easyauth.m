//FIXME: license

#import <Cordova/CDV.h>
#import <AzureEasyAuth/AzureEasyAuth.h>

@interface EasyAuth : CDVPlugin {
}

@property (strong, nonatomic) MSLoginSafariViewController *loginController;

- (void)login:(CDVInvokedUrlCommand *)command;

@end

@implementation EasyAuth

- (void)login:(CDVInvokedUrlCommand*)command {
    NSString* provider = [command.arguments objectAtIndex:0];
    NSDictionary* parameters = [command.arguments objectAtIndex:1];
    NSString* loginHost = [command.arguments objectAtIndex:2];
    NSString* loginUriPrefix = [command.arguments objectAtIndex:3];

    NSString *easyAuthAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"EASYAUTH_APPID"];

    // FIXME: remove hardcoding
    self.loginController = [[MSLoginSafariViewController alloc] initWithBackendUrl:@"https://shrirs-demo.azurewebsites.net"];

    [self.loginController loginWithProvider:provider urlScheme:easyAuthAppId parameters:parameters controller:self.viewController animated:NO completion:^(MSUser * _Nullable user, NSError * _Nullable error) {
        if (user) {
            NSDictionary *userDict = @{
                @"user": @{
                    @"userId": user.userId
                },
                @"authenticationToken": user.mobileServiceAuthenticationToken
            };
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userDict];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        } else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: [error description]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }
    }];
}

- (void)handleOpenURL:(NSNotification*)notification {
    NSURL* url = [notification object];
    [self.loginController resumeWithURL:url];
}

@end

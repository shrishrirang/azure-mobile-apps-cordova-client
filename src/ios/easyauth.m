// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------

#import <Cordova/CDV.h>
#import <AzureEasyAuth/AzureEasyAuth.h>

// These constants should match the values in plugin.xml
static const NSString * const defaultEasyAuthId = @"default-easyauth-app-id";
static const NSString * const appIdKey = @"com.microsoft.azure.easyauth.appid";

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

    NSString *easyAuthAppId = [[NSBundle mainBundle] objectForInfoDictionaryKey:appIdKey];
    if ([easyAuthAppId isEqualToString:defaultEasyAuthId]) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Variable EASYAUTH_APPID not defined while installing cordova-plugin-ms-azure-mobile-apps plugin"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    // TODO: Use the specified loginUriPrefix once https://github.com/Azure/azure-mobile-apps-ios-client/issues/132 is fixed.
    self.loginController = [[MSLoginSafariViewController alloc] initWithBackendUrl:loginHost];

    [self.loginController loginWithProvider:provider urlScheme:easyAuthAppId parameters:parameters controller:self.viewController animated:NO completion:^(MSUser * _Nullable user, NSError * _Nullable error) {
        if (user) { // Success
            NSDictionary *userDict = @{
                @"user": @{
                    @"userId": user.userId
                },
                @"authenticationToken": user.mobileServiceAuthenticationToken
            };
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userDict];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        } else { // Failure
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

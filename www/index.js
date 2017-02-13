// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------

var exec = require('cordova/exec');

// FIXME: comment
function loginWithOptions(options, callback) {

    function success(result) {
        callback(result);
    }

    function error(errorString) {
        callback(undefined, new Error(errorString));
    }

    exec(success, error, "EasyAuth", "login", [options.provider, options.queryParameters, options.loginHost, options.loginUriPrefix]);
}

var WindowsAzure = require('cordova-plugin-ms-azure-mobile-apps.AzureMobileServices');

WindowsAzure.configure({
    config: {
        login: {
            loginWithOptions: loginWithOptions
        }
    }
});

module.exports = WindowsAzure;

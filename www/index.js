// FIXME license

var exec = require('cordova/exec');

function loginWithOptions(options, callback) {
    function success(result) {
        callback(result, null);
    }

    function error(err) {
        callback(null, err);
    }

    exec(success, error, "EasyAuth", "login", [options.provider, options.queryParameters, options.loginHost, options.loginUriPrefix]);
}

var WindowsAzure = require('cordova-plugin-ms-azure-mobile-apps.AzureMobileServices');
WindowsAzure.configure({
    definitions: {
        login: {
            loginWithOptions: loginWithOptions
        }
    }
});

module.exports = WindowsAzure;

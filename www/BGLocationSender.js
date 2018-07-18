var exec = require('cordova/exec');

var locationService = {
    start:function(arg0, success, error) {
        exec(success, error, "BGLocationSender", "start", [arg0]);
    },
    stop:function(arg0, success, error) {
        exec(success, error, "BGLocationSender", "stop", [arg0]);
    },
    updateParams:function(arg0, success, error) {
        exec(success, error, "BGLocationSender", "updateParams", [arg0]);
    },
    getLocation:function(success, error) {
        exec(success, error, "BGLocationSender", "getLocation", [{}]);
    },
};

module.exports = locationService;

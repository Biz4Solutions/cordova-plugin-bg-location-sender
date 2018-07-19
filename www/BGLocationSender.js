var exec = require('cordova/exec');

var locationService = {
    start:function(success, error, arg0) {
        exec(success, error, "BGLocationSender", "start", [arg0]);
    },
    stop:function(success, error) {
        exec(success, error, "BGLocationSender", "stop", []);
    },
    updateParams:function(success, error, arg0) {
        exec(success, error, "BGLocationSender", "updateParams", [arg0]);
    },
    getLocation:function(success, error) {
        exec(success, error, "BGLocationSender", "getLocation", [{}]);
    },
};

module.exports = locationService;

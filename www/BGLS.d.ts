interface CordovaPlugins {
    BGLocationSender: BGLocationSender;
}

interface BGLocationSender {
    start(arg0: any, success: any, error: any): void;
    stop(arg0: any, success: any, error: any): void;
    updateParams(arg0: any, success: any, error: any): void;
    getLocation(success: any, error: any): void;
}
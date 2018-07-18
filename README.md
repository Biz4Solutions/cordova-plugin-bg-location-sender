# Background Location Save
	
	This plugin uses to store user location to a database when a app is in the background.
	
# Installation

	ionic cordova plugin add cordova-plugin-bg-location-sender --save

# How to call

	-------------------------------------------------------------
	declare cordova in your ts -- above Component.
	import .... 
	declare var cordova: any;
	@Component( {
		....
	})
	
	-------------------------------------------------------------
	BACKEND
	-------------------------------------------------------------
	let params = {
		"dbName": "BACKEND",
		"parameters": {
			"url": "https://../updatePosition"
			"methodType": "POST",
			"header": {
				"key": "value" 		// Optional //add your all header with key value.
			},
			"notificationTitle":"", // Optional
			"notificationText":""   // Optional
		},
        "params": {
            "key": "value" 			// Optional //add your all body params with key value. This body params is store in db with lat long.
        },
        "locationSendIntervalTime": 5000
    }

	-------------------------------------------------------------
	FIREBASE
	-------------------------------------------------------------
	let params = {
		"dbName": "FIREBASE",
		"parameters": {
			"url": "https://xyz.firebaseio.com"
			"firebaseEmail":"",
			"firebasePassword":"",
			"firebaseDBName":"",
			"firebaseDBKey":"",
			"notificationTitle":"", // Optional
			"notificationText":"" 	// Optional
		},
        "params": {
            "key": "value"  		// Optional //add your all body params with key value. This body params is store in db with lat long.
        },
        "locationSendIntervalTime": 5000
    }
   
    -------------------------------------------------------------
	FRONTEND
	-------------------------------------------------------------
	let params = {
		"dbName": "FRONTEND",
		"parameters": {
			"notificationTitle":"", // Optional
			"notificationText":""   // Optional
		},
        "locationSendIntervalTime": 5000
    }
	
	-------------------------------------------------------------
	cordova.plugins.BGLocationSender.start(params,
	(s)=>{console.log("aa --------- s=",s);},
	(e)=>{console.log("aa --------- error=",e);});
	
	
# Add keys into plist for iOS

	-------------------------------------------------------------
	<key>NSLocationAlwaysUsageDescription</key>
	<string>We will require to send your current location information to server to continue using our app</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>By accessing your location, this app will use current location information for better results.</string>

	-------------------------------------------------------------
	for iOS - Project setting capabilities section - "ON" Background Modes - check "Location Updates"
	-------------------------------------------------------------
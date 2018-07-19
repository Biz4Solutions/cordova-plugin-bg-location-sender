# Background Location Save
	This plugin is used to store users geo location to a data store when an ionic app is running in the background.
	Data store can be a backend API, firebase or for frontend use it as a location watcher
	
## Installation
	```
	ionic cordova plugin add cordova-plugin-bg-location-sender --save
	npm install --save @ionic-native/bg-location-sender 
	```
	
## Supported Cordova Versions
	- cordova: `>= 6`
	- cordova-android: `>= 6.3`
	- cordova-ios: `>= 4`
	
### Setup
	Download your Firebase configuration files, GoogleService-Info.plist for ios and google-services.json for android, and place them in the root folder of your cordova project.  Check out this [firebase article](https://support.google.com/firebase/answer/7015592) for details on how to download the files.

	```
	- My Project/
		platforms/
		plugins/
		www/
		config.xml
		google-services.json       <--
		GoogleService-Info.plist   <--
		...
	```

#### IMPORTANT NOTES
	- This plugin uses a hook (after prepare) that copies the configuration files to the right place, namely `platforms/ios/\<My Project\>/Resources` for ios and `platforms/android` for android.
	- Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.

### PhoneGap Build
	Hooks do not work with PhoneGap Build. This means you will have to manually make sure the configuration files are included. One way to do that is to make a private fork of this plugin and replace the placeholder config files (see `src/ios` and `src/android`) with your actual ones, as well as hard coding your app id and api key in `plugin.xml`.

### Google Play Services
	Your build may fail if you are installing multiple plugins that use Google Play Services.  This is caused by the plugins installing different versions of the Google Play Services library.  This can be resolved by installing [cordova-android-play-services-gradle-release](https://github.com/dpa99c/cordova-android-play-services-gradle-release).

### Methodes
	1) start - use to start location watcher to store location.
	2) stop - use to stop location watcher.
	3) updateParams - use to update params when location watcher is start.
	4) getLocation - use to get location ones.

#### Example
	
##### import BGLocationSender and add in constructor
	import { BGLocationSender, BGLocationSenderOptions } from '@ionic-native/bg-location-sender';
	
	constructor( private bgls:BGLocationSender){
	}
	
##### How to call

	-------------------------------------------------------------
	storeType BACKEND
	-------------------------------------------------------------
	let params: BGLocationSenderOptions = {
		storeType: "BACKEND",
		parameters: {
			url: "https://../updatePosition"
			methodType: "POST",
			header: {
				"key": "value" 		// Optional //add your all header with key value.
			},
			notificationTitle:"", 	// Optional
			notificationText:""   	// Optional
		},
        params: {
            "key": "value" 			// Optional //add your all body params with key value. This body params is store in db with lat long.
        },
        locationSendIntervalTime: 5000
    }

	-------------------------------------------------------------
	storeType FIREBASE
	-------------------------------------------------------------
	let params: BGLocationSenderOptions = {
		storeType: "FIREBASE",
		parameters: {
			url: "https://xyz.firebaseio.com"
			firebaseEmail:"",
			firebasePassword:"",
			firebaseDBName:"",
			firebaseDBKey:"",
			notificationTitle:"", 	// Optional
			notificationText:"" 	// Optional
		},
        params: {
            "key": "value"  		// Optional //add your all body params with key value. This body params is store in db with lat long.
        },
        locationSendIntervalTime: 5000
    }
   
    -------------------------------------------------------------
	storeType FRONTEND
	-------------------------------------------------------------
	let params: BGLocationSenderOptions = {
		storeType: "FRONTEND",
		parameters: {
			notificationTitle:"", 	// Optional
			notificationText:""   	// Optional
		},
        locationSendIntervalTime: 5000
    }
	
	this.bgls.start(params).subscribe( values => {
	   console.log("aa ---------- values=",values);
    });
	
	
# Add keys into plist for iOS

	-------------------------------------------------------------
	<key>NSLocationAlwaysUsageDescription</key>
	<string>We will require to send your current location information to server to continue using our app</string>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>By accessing your location, this app will use current location information for better results.</string>

	-------------------------------------------------------------
	for iOS - Project setting capabilities section - "ON" Background Modes - check "Location Updates"
	-------------------------------------------------------------
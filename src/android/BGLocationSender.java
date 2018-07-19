package com.plugin.BGLocationSender;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import plugin.com.bglocationsender.CallBackListener;
import plugin.com.bglocationsender.ForegroundService;

import android.os.Build;

/**
 * This class echoes a string called from JavaScript.
 */
public class BGLocationSender extends CordovaPlugin {

	// public Context context = null;
	private JSONObject paramsObject = null;
	private JSONObject parameterObject = null;
	String[] permissions = { Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION };
	CallbackContext callbackContext;

	@Override
	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		try {
			System.out.println("aa ----------BGLocationSender java action="+action);
			System.out.println("aa ----------BGLocationSender java action="+args.toString());
			this.callbackContext = callbackContext;
			if (action == null) {
				return false;
			}
			if (action.equals("start")) {
				paramsObject = args.getJSONObject(0);
				parameterObject = paramsObject.getJSONObject("parameters");
				if (!PermissionHelper.hasPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
						|| !PermissionHelper.hasPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
					PermissionHelper.requestPermissions(this, 150, permissions);
				} else {
					this.startService(callbackContext);
				}
				return true;
			} else if (action.equals("stop")) {
				paramsObject = null;
				parameterObject = null;
				clearPreference(this.cordova.getActivity());
				this.stopService(callbackContext);
				return true;
			} else if (action.equals("updateParams")) {
				this.updateParams(args.getJSONObject(0), callbackContext);
				return true;
			} else if (action.equals("getLocation")) {
				if (!PermissionHelper.hasPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION)
						|| !PermissionHelper.hasPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
					PermissionHelper.requestPermissions(this, 149, permissions);
				} else {
					this.getLocation(callbackContext);
				}
				return true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}

	private void startService(final CallbackContext callbackContext) {
		stopService(callbackContext);
		if (paramsObject != null && parameterObject != null) {
			try {
				if (paramsObject.getLong("locationSendIntervalTime") <= 0) {
					callbackContext.error("Missing locationSendIntervalTime");
					return;
				}
				if (paramsObject.getString("storeType") != null) {
					if (paramsObject.getString("storeType").equalsIgnoreCase("FIREBASE")) {
						if (parameterObject.getString("url") == null || parameterObject.getString("url").equals("")) {
							callbackContext.error("Missing Firebase Url");
							return;
						} else if (parameterObject.getString("firebaseEmail") == null
								|| parameterObject.getString("firebaseEmail").equals("")) {
							callbackContext.error("Missing Firebase Email");
							return;
						} else if (parameterObject.getString("firebasePassword") == null
								|| parameterObject.getString("firebasePassword").equals("")) {
							callbackContext.error("Missing Firebase Password");
							return;
						} else if (parameterObject.getString("firebaseDBName") == null
								|| parameterObject.getString("firebaseDBName").equals("")) {
							callbackContext.error("Missing Firebase DB Refrance Name");
							return;
						} else if (parameterObject.getString("firebaseDBKey") == null
								|| parameterObject.getString("firebaseDBKey").equals("")) {
							callbackContext.error("Missing Firebase DB Refrance Key");
							return;
						}
					} else if (paramsObject.getString("storeType").equalsIgnoreCase("BACKEND")) {
						if (parameterObject.getString("url") == null || parameterObject.getString("url").equals("")) {
							callbackContext.error("Missing url");
							return;
						} else if (parameterObject.getString("methodType") == null
								|| parameterObject.getString("methodType").equals("")) {
							callbackContext.error("Missing methodType");
							return;
						}
					}
				}

				JSONObject jsonObj = new JSONObject();
				jsonObj.put("message", "BGLocationSender started successfully");
				PluginResult pluginresult = new PluginResult(PluginResult.Status.OK, jsonObj);
	            pluginresult.setKeepCallback(true);
	            callbackContext.sendPluginResult(pluginresult);

				storeStringPreference(this.cordova.getActivity(), paramsObject.toString());
				Intent intent = new Intent(this.cordova.getActivity(), ForegroundService.class);
				try {
					if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
						this.cordova.getActivity().startService(intent);
					} else {
						this.cordova.getActivity().startForegroundService(intent);
					}
					if (paramsObject.getString("storeType") == null || paramsObject.getString("storeType").equals("")
							|| paramsObject.getString("storeType").equalsIgnoreCase("FRONTEND")) {
						ForegroundService.setCallBackListener(new CallBackListener<JSONObject>() {
							@Override
							public void onLocationChanged(JSONObject result) {
								if(callbackContext != null){
									PluginResult pluginresult = new PluginResult(PluginResult.Status.OK, result);
						            pluginresult.setKeepCallback(true);
						            callbackContext.sendPluginResult(pluginresult);
								}
							}
						});
					}
				} catch (Exception e) {
					e.printStackTrace();
				}

			} catch (Exception e) {
				e.printStackTrace();
				System.out.println("aa -BGLocationSender- stopService Exception=" + e);
				callbackContext.error("" + e);
			}
		} else {
			callbackContext.error("Expected one non-empty parameter argument.");
		}
	}

	private void stopService(CallbackContext callbackContext) {
		try {
			this.cordova.getActivity().stopService(new Intent(this.cordova.getActivity(), ForegroundService.class));
			//callbackContext.success("BGLocationSender stopService successfully");
		} catch (Exception e) {
			callbackContext.error("" + e);
			System.out.println("aa -BGLocationSender- stopService Exception=" + e);
		}
	}

	private void getLocation(CallbackContext callbackContext) {
		try {
			LocationManager locationManager = (LocationManager) this.cordova.getActivity()
					.getSystemService(Context.LOCATION_SERVICE);
			Location location = null;
			// Getting GPS status
			boolean isGPSEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
			// Getting network status
			boolean isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
			if (isNetworkEnabled) {
				location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
			}
			if (isGPSEnabled) {
				location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
			}
			if (location != null) {
				JSONObject jsonObj = new JSONObject();
				jsonObj.put("latitude", location.getLatitude());
				jsonObj.put("longitude", location.getLongitude());
				callbackContext.success(jsonObj);
			} else {
				callbackContext.error("location is not found");
			}
		} catch (Exception e) {
			callbackContext.error("" + e);
			System.out.println("aa -BGLocationSender- stopService Exception=" + e);
		}
	}

	@Override
	public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) {
		for (int r : grantResults) {
			if (r == PackageManager.PERMISSION_DENIED) {
				// LOG.d("LOCATION", "Permission Denied!");
				return;
			}
		}
		if (callbackContext != null) {
			if (requestCode == 149) {
				this.getLocation(callbackContext);
			} else if (requestCode == 150) {
				this.startService(callbackContext);
			}
		}
	}
	
	private void updateParams(JSONObject updatedParamsObject, CallbackContext callbackContext) {
		try {
			if (updatedParamsObject.getLong("locationSendIntervalTime") <= 0) {
				callbackContext.error("Missing locationSendIntervalTime");
				return;
			}
			if (updatedParamsObject.getString("storeType") != null) {
				JSONObject updatedParameterObject = paramsObject.getJSONObject("parameters");
				if (updatedParamsObject.getString("storeType").equalsIgnoreCase("FIREBASE")) {
					if (updatedParameterObject.getString("url") == null || updatedParameterObject.getString("url").equals("")) {
						callbackContext.error("Missing Firebase Url");
						return;
					} else if (updatedParameterObject.getString("firebaseEmail") == null
							|| updatedParameterObject.getString("firebaseEmail").equals("")) {
						callbackContext.error("Missing Firebase Email");
						return;
					} else if (updatedParameterObject.getString("firebasePassword") == null
							|| updatedParameterObject.getString("firebasePassword").equals("")) {
						callbackContext.error("Missing Firebase Password");
						return;
					} else if (updatedParameterObject.getString("firebaseDBName") == null
							|| updatedParameterObject.getString("firebaseDBName").equals("")) {
						callbackContext.error("Missing Firebase DB Refrance Name");
						return;
					} else if (updatedParameterObject.getString("firebaseDBKey") == null
							|| updatedParameterObject.getString("firebaseDBKey").equals("")) {
						callbackContext.error("Missing Firebase DB Refrance Key");
						return;
					}
				} else if (updatedParamsObject.getString("storeType").equalsIgnoreCase("BACKEND")) {
					if (updatedParameterObject.getString("url") == null || updatedParameterObject.getString("url").equals("")) {
						callbackContext.error("Missing url");
						return;
					} else if (updatedParameterObject.getString("methodType") == null
							|| updatedParameterObject.getString("methodType").equals("")) {
						callbackContext.error("Missing methodType");
						return;
					}
				}
			}
			paramsObject = updatedParamsObject;
			JSONObject jsonObj = new JSONObject();
			jsonObj.put("message", "BGLocationSender updated successfully");
			callbackContext.success(jsonObj);
			storeStringPreference(this.cordova.getActivity(), updatedParamsObject.toString());
		} catch (Exception e) {
			callbackContext.error("" + e);
			System.out.println("aa -BGLocationSender- stopService Exception=" + e);
		}
	}

	private void clearPreference(Context context) {
		SharedPreferences settings = context.getSharedPreferences("PARAMS_OBJECT", Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = settings.edit();
		editor.clear();
		editor.apply();
	}

	private void storeStringPreference(Context context, String value) {
		SharedPreferences settings = context.getSharedPreferences("PARAMS_OBJECT", Context.MODE_PRIVATE);
		SharedPreferences.Editor editor = settings.edit();
		editor.putString("PARAMS_OBJECT_KEY", value);
		editor.apply();
	}
}
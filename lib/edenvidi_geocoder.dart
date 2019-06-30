import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:latlong/latlong.dart';

class EdenvidiGeocoder {
	static const MethodChannel _channel = const MethodChannel('com.edenvidi.geocoder');
	static Future<List<Address>> latLngToAddresses(final LatLng location, { final int limit = 25 } ) async {
		try {
			final List addresses = await _channel.invokeMethod("latLngToAddress", <String, dynamic>{
				"latitude": location.latitude,
				"longitude": location.longitude,
				"limit": limit,
			}) as List;
			if ( addresses == null ) return null;
			return addresses.map( ( address ) => Address.fromMap( address as Map ) ).toList(growable: false);
		} catch (error) {
			rethrow;
		}
	}
	static Future<Address> latLngToAddress(final LatLng location) async {
		try {
			final List addresses = await _channel.invokeMethod("latLngToAddress", <String, dynamic>{
				"latitude": location.latitude,
				"longitude": location.longitude,
				"limit": 1,
			}) as List;
			if( addresses == null || addresses.length == 0 ) return null;
			else return addresses.map( ( address ) => Address.fromMap( address as Map ) ).toList(growable: false).first;
		} catch (error) {
			rethrow;
		}
	}
	
	static Future<List<Address>> addressToLatLngs( final String address, { final int limit = 25 } ) async {
		try {
			List addresses = await _channel.invokeMethod("addressToLatLng", <String, dynamic> {
				"address": address,
				"limit": limit,
			}) as List;
			if ( addresses == null ) return null;
			return addresses.map( ( address ) => Address.fromMap( address as Map ) ).toList(growable: false);
		} catch (error) {
			rethrow;
		}
	}
	static Future<Address> addressToLatLng( final String address ) async {
		try {
			List addresses = await _channel.invokeMethod("addressToLatLng", <String, dynamic> {
				"address": address,
				"limit": 1,
			}) as List;
			if( addresses == null || addresses.length == 0 ) return null;
			else return addresses.map( ( address ) => Address.fromMap( address as Map ) ).toList(growable: false).first;
		} catch (error) {
			rethrow;
		}
	}
	
	static Future<String> get platformVersion async {
		final String version = await _channel.invokeMethod('getPlatformVersion');
		return version;
	}
}

@immutable
class Address {
	/// The geographic coordinates.
	final LatLng coordinate;
	
	/// The formatted address with all lines.
	final String addressLine;
	
	/// The localized country name of the address.
	final String countryName;
	
	/// The country code of the address.
	final String countryCode;
	
	/// The feature name of the address.
	final String featureName;
	
	/// The postal code.
	final String postalCode;
	
	/// The administrative area name of the address
	final String adminArea;
	
	/// The sub-administrative area name of the address
	final String subAdminArea;
	
	/// The locality of the address
	final String locality;
	
	/// The sub-locality of the address
	final String subLocality;
	
	/// The thoroughfare name of the address
	final String thoroughfare;
	
	/// The sub-thoroughfare name of the address
	final String subThoroughfare;
	
	Address({this.coordinate, this.addressLine, this.countryName, this.countryCode, this.featureName, this.postalCode, this.adminArea, this.subAdminArea, this.locality, this.subLocality, this.thoroughfare, this.subThoroughfare});
	
	/// Creates an address from a map containing its properties.
	Address.fromMap(Map map) :
			this.coordinate = new LatLng(map["coordinates"]["latitude"] as double, map["coordinates"]["longitude"] as double),
			this.addressLine = map["addressLine"] as String,
			this.countryName = map["countryName"] as String,
			this.countryCode = map["countryCode"] as String,
			this.featureName = map["featureName"] as String,
			this.postalCode = map["postalCode"] as String,
			this.locality = map["locality"] as String,
			this.subLocality = map["subLocality"] as String,
			this.adminArea = map["adminArea"] as String,
			this.subAdminArea = map["subAdminArea"] as String,
			this.thoroughfare = map["thoroughfare"] as String,
			this.subThoroughfare = map["subThoroughfare"] as String;
}

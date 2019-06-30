import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:edenvidi_geocoder/edenvidi_geocoder.dart';
import 'package:latlong/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	final GlobalKey<ScaffoldState> _scaffold_state = new GlobalKey();
	String _platformVersion = 'Unknown';
	
	Address _address = null;
	LatLng _latlng = null;
	
	TextEditingController _latitude_controller, _longitude_controller, _address_controller;
	
	@override
	Widget build(BuildContext context) {
		return new MaterialApp(
			home: new Scaffold(
				key: _scaffold_state,
				appBar: new AppBar(
					title: const Text('Edenvidi geocoder plugin example app'),
				),
				body: new ListView(
					padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
					children: <Widget>[
						new Center(
							child: new Text(
								_platformVersion,
							),
						),
						new Divider(
							height: 50.0,
						),
						//begin lat long to address
						new TextField(
							controller: _latitude_controller,
							decoration: const InputDecoration(
								labelText: "Latitude",
							),
							keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
						),
						new SizedBox(
							height: 20.0,
						),
						new TextField(
							controller: _longitude_controller,
							decoration: const InputDecoration(
								labelText: "longitude",
							),
							keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
						),
						new SizedBox(
							height: 20.0,
						),
						new RaisedButton(
							child: new Text(
								"Get the address from latitude and longitude",
							),
							onPressed: _latLongToAddress,
						),
						new SizedBox(
							height: 20.0,
						),
						new Text(
							_address == null ? "No address" : _address.addressLine,
						),
						//end lat long to addresss
						
						new Divider(
							height: 50.0,
						),
						
						//begin address to lat long
						new TextField(
							controller: _address_controller,
							decoration: const InputDecoration(
								labelText: "Address",
							),
							maxLines: 5,
						),
						new SizedBox(
							height: 20.0,
						),
						new RaisedButton(
							child: new Text(
								"Get the latitude and longitude from address",
							),
							onPressed: _addressToLatLong,
						),
						new SizedBox(
							height: 20.0,
						),
						new Text(
							"latitude: ${ _latlng?.latitude ?? "-" }",
						),
						new Text(
							"longitude: ${ _latlng?.longitude ?? "-" }",
						),
						//end address to lat long
					],
				),
			),
		);
	}
	
	void _latLongToAddress() async {
		final latitude = double.tryParse( _latitude_controller.text ) ?? 0;
		final longitude = double.tryParse( _longitude_controller.text ) ?? 0;
		final address = await EdenvidiGeocoder.latLngToAddress( new LatLng( latitude, longitude ) );
		if ( address == null ) {
			_scaffold_state.currentState.showSnackBar( new SnackBar(
				content: new Text(
					"Invalid latitude and longitude",
				),
			) );
		} else {
			if ( mounted ) {
				setState(() {
					_address = address;
				});
			}
		}
	}
	
	void _addressToLatLong() async {
		final latlng = await EdenvidiGeocoder.addressToLatLng( _address_controller.text );
		if ( latlng == null ) {
			_scaffold_state.currentState.showSnackBar( new SnackBar(
				content: new Text(
					"Invalid address",
				),
			) );
		} else {
			if ( mounted ) {
				setState(() {
					_latlng = latlng.coordinate;
				});
			}
		}
	}
	
	@override
	void initState() {
		_latitude_controller = new TextEditingController();
		_longitude_controller = new TextEditingController();
		_address_controller = new TextEditingController();
		super.initState();
		initPlatformState();
		_latitude_controller.text = "-6.175044";
		_longitude_controller.text = "106.825795";
		_address_controller.text = "Jl. Tugu Monas, RT.5/RW.2, Gambir, Kecamatan Gambir, Kota Jakarta Pusat, Daerah Khusus Ibukota Jakarta 10110, Indonesia";
	}
	
	@override
	void dispose() {
		_latitude_controller.dispose();
		_longitude_controller.dispose();
		_address_controller.dispose();
		super.dispose();
	}
	
	// Platform messages are asynchronous, so we initialize in an async method.
	Future<void> initPlatformState() async {
		String platformVersion;
		// Platform messages may fail, so we use a try/catch PlatformException.
		try {
			platformVersion = await EdenvidiGeocoder.platformVersion;
		} on PlatformException {
			platformVersion = 'Failed to get platform version.';
		}
		
		// If the widget was removed from the tree while the asynchronous platform
		// message was in flight, we want to discard the reply rather than calling
		// setState to update our non-existent appearance.
		if (!mounted) return;
		
		setState(() {
			_platformVersion = platformVersion;
		});
	}
	
}

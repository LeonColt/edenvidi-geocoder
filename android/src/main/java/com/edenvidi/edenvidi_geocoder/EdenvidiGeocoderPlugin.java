package com.edenvidi.edenvidi_geocoder;

import android.content.Context;
import android.location.Address;
import android.location.Geocoder;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** EdenvidiGeocoderPlugin */
public class EdenvidiGeocoderPlugin implements MethodCallHandler {
    private final Geocoder geocoder;

    private EdenvidiGeocoderPlugin(Context context) {
        this.geocoder = new Geocoder( context );
    }

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "com.edenvidi.geocoder");
        channel.setMethodCallHandler(new EdenvidiGeocoderPlugin( registrar.context() ));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch ( call.method ) {
            case "latLngToAddress":
                handleLatLngToAddress(call, result);
                break;
            case "addressToLatLng":
                handleAddressToLatLng(call, result);
                break;
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            default:
                result.notImplemented();
                break;
        }
    }


    private void handleLatLngToAddress(MethodCall call, final MethodChannel.Result res) {
        //noinspection ConstantConditions
        final double latitude = call.argument("latitude");
        //noinspection ConstantConditions
        final double longitude = call.argument("longitude");
        //noinspection ConstantConditions
        final int limit = call.argument("limit");

        try {
            final List<Address> addresses = geocoder.getFromLocation(latitude, longitude, limit);
            res.success( createAddressMapList(addresses) );
        } catch (IOException e) {
            res.error(e.getMessage(), e.getLocalizedMessage(), e.getStackTrace());
        }
    }

    private void handleAddressToLatLng(MethodCall call, final MethodChannel.Result res) {
        final String address = call.argument("address");
        //noinspection ConstantConditions
        final int limit = call.argument("limit");

        try {
            final List<Address> addresses = geocoder.getFromLocationName(address, limit);
            res.success(createAddressMapList(addresses));
        } catch (IOException e) {
            res.error(e.getMessage(), e.getLocalizedMessage(), e.getStackTrace());
        }
    }

    private Map<String, Object> createCoordinatesMap(Address address) {

        if(address == null)
            return null;

        Map<String, Object> result = new HashMap<>();

        result.put("latitude", address.getLatitude());
        result.put("longitude", address.getLongitude());

        return result;
    }

    private Map<String, Object> createAddressMap(Address address) {

        if(address == null)
            return null;

        // Creating formatted address
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i <= address.getMaxAddressLineIndex(); i++) {
            if (i > 0) {
                sb.append(", ");
            }
            sb.append(address.getAddressLine(i));
        }

        Map<String, Object> result = new HashMap<>();

        result.put("coordinates", createCoordinatesMap(address));
        result.put("featureName", address.getFeatureName());
        result.put("countryName", address.getCountryName());
        result.put("countryCode", address.getCountryCode());
        result.put("locality", address.getLocality());
        result.put("subLocality", address.getSubLocality());
        result.put("thoroughfare", address.getThoroughfare());
        result.put("subThoroughfare", address.getSubThoroughfare());
        result.put("adminArea", address.getAdminArea());
        result.put("subAdminArea", address.getSubAdminArea());
        result.put("addressLine", sb.toString());
        result.put("postalCode", address.getPostalCode());

        return result;
    }
    private List<Map<String, Object>> createAddressMapList(List<Address> addresses) {

        if(addresses == null)
            return new ArrayList<>();

        List<Map<String, Object>> result = new ArrayList<>(addresses.size());

        for (Address address : addresses) {
            result.add(createAddressMap(address));
        }

        return result;
    }

}

package mobi.esys.fragments;

import java.io.*;

import android.graphics.*;
import android.graphics.drawable.*;
import android.view.*;

import com.directions.route.*;
import com.google.android.gms.maps.*;
import com.google.android.gms.maps.model.*;

import mobi.esys.constants.WIIConsts;
import mobi.esys.where3.R;
import android.app.Activity;
import android.app.Fragment;
import android.location.Location;
import android.media.ExifInterface;
import android.net.ParseException;
import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMap.OnMyLocationChangeListener;
import com.google.android.gms.maps.MapFragment;

public class WIIMapFragment extends Fragment implements RoutingListener,
		OnMyLocationChangeListener {
	private transient View view;
	private transient GoogleMap map;
	private transient double prevLat;
	private transient double prevLon;
	private transient boolean isFirstTime;
	private transient Activity parentActivity;

	private transient int PICTURE_SIZE = WIIConsts.PICTURE_SIZE;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		view = inflater.inflate(R.layout.fragment_wiimap, container, false);

		initMap();

		prevLat = 0.0;
		prevLon = 0.0;
		isFirstTime = true;
		parentActivity = getActivity();

		return view;
	}

	private void initMap() {
		map = ((MapFragment) getFragmentManager().findFragmentById(R.id.map))
				.getMap();
		map.setMyLocationEnabled(true);
		map.setOnMyLocationChangeListener(this);
		map.setMapType(GoogleMap.MAP_TYPE_SATELLITE);
	}

	void getCurrentLocation() {
		Location myLocation = map.getMyLocation();
		if (myLocation != null) {

			double dLatitude = myLocation.getLatitude();
			double dLongitude = myLocation.getLongitude();

			prevLat = dLatitude;
			prevLon = dLongitude;

			Log.i("APPLICATION", " : " + dLatitude);
			Log.i("APPLICATION", " : " + dLongitude);

			if (isFirstTime) {
				moveCamera(dLatitude, dLongitude);
			}

			Drawable drawable = Drawable.createFromPath(getArguments()
					.getString("picFile"));
			LatLng start = new LatLng(dLatitude, dLongitude);
			LatLng end = readGeoTagImage(getArguments().getString("picFile"));

			map.addMarker(new MarkerOptions().position(end).icon(
					BitmapDescriptorFactory.fromBitmap(Bitmap
							.createScaledBitmap(
									((BitmapDrawable) drawable).getBitmap(),
									PICTURE_SIZE, PICTURE_SIZE, true))));

			startRouting(start, end);

		}

	}

	private void startRouting(LatLng start, LatLng end) {
		Routing routing = new Routing(Routing.TravelMode.DRIVING);
		routing.registerListener(this);
		routing.execute(start, end);
	}

	private void moveCamera(double dLatitude, double dLongitude) {
		CameraUpdate zoom = CameraUpdateFactory.zoomTo(WIIConsts.PICTURE_ZOOM);

		CameraUpdate center = CameraUpdateFactory.newLatLng(new LatLng(
				dLatitude, dLongitude));
		map.moveCamera(center);
		map.animateCamera(zoom);
		isFirstTime = false;
	}

	@Override
	public void onRoutingFailure() {
		Toast.makeText(
				parentActivity,
				parentActivity.getResources().getString(R.string.route_failure),
				Toast.LENGTH_SHORT).show();
	}

	@Override
	public void onRoutingStart() {

	}

	@Override
	public void onRoutingSuccess(PolylineOptions mPolyOptions, Route route) {
		Toast.makeText(
				getActivity(),
				parentActivity.getResources().getString(R.string.route_success),
				Toast.LENGTH_SHORT).show();
		makeRoute(mPolyOptions);
	}

	private void makeRoute(PolylineOptions mPolyOptions) {
		PolylineOptions polyoptions = new PolylineOptions();
		polyoptions.color(Color.RED);
		polyoptions.width(WIIConsts.ROUTE_LINE_WIDTH);
		polyoptions.addAll(mPolyOptions.getPoints());
		map.addPolyline(polyoptions);
	}

	public LatLng readGeoTagImage(String imagePath) {
		LatLng loc = new LatLng(0.0, 0.0);
		try {
			ExifInterface exif = new ExifInterface(imagePath);
			float[] latlong = new float[2];
			if (exif.getLatLong(latlong)) {
				loc = new LatLng(latlong[0], latlong[1]);
				Log.d("loc",
						String.valueOf(latlong[0]) + ":"
								+ String.valueOf(latlong[1]));
			}

		} catch (IOException e) {
			e.printStackTrace();
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return loc;
	}

	@Override
	public void onMyLocationChange(Location arg0) {
		if (prevLat != arg0.getLatitude() || prevLon != arg0.getLongitude()) {
			getCurrentLocation();
		}
	}
}

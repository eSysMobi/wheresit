package mobi.esys.fragments;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

import mobi.esys.adapters.PlaceAdapter;
import mobi.esys.constants.WIIConsts;
import mobi.esys.datatypes.Place;
import mobi.esys.tasks.GetFSVenuesTask;
import mobi.esys.tasks.GetGooglePlaces;
import mobi.esys.where3.MainActivity;
import mobi.esys.where3.R;
import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.Session.StatusCallback;
import com.facebook.SessionState;
import com.facebook.UiLifecycleHelper;
import com.facebook.model.GraphPlace;

public class MenuFragment extends Fragment implements LocationListener,
		OnItemClickListener, StatusCallback {
	private transient View view;
	private transient ListView placeList;
	private transient LocationManager locationManager;
	private transient Activity parentActivity;
	private transient Location userLoc;
	private List<Place> places;
	private transient UiLifecycleHelper uiHelper;

	private static final String CAM_FRAG_TAG = WIIConsts.CAMERA_FRAGMENT_TAG;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		view = inflater.inflate(R.layout.fragment_menu, container, false);

		parentActivity = getActivity();
		uiHelper = new UiLifecycleHelper(parentActivity, this);
		uiHelper.onCreate(savedInstanceState);

		locationManager = (LocationManager) getActivity().getSystemService(
				Context.LOCATION_SERVICE);

		Criteria criteria = new Criteria();

		locationManager.requestLocationUpdates(
				locationManager.getBestProvider(criteria, true), 0, 0, this);

		if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
			Location lastKnown = locationManager
					.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
			Bundle locBundle = new Bundle();

			locBundle.putDouble("lat", lastKnown.getLatitude());
			locBundle.putDouble("lon", lastKnown.getLongitude());

			GetGooglePlaces getGooglePlaces = new GetGooglePlaces();
			getGooglePlaces.execute(locBundle);

			GetFSVenuesTask fsVenuesTask = new GetFSVenuesTask();
			fsVenuesTask.execute(locBundle);

			places = new ArrayList<Place>();

			try {
				places = getGooglePlaces.get();
			} catch (InterruptedException e) {
			} catch (ExecutionException e) {
			}
			userLoc = new Location("");
			userLoc.setLatitude(lastKnown.getLatitude());
			userLoc.setLongitude(lastKnown.getLongitude());
			ArrayAdapter<Place> adapter = new PlaceAdapter(parentActivity,
					R.layout.menu_item, places, userLoc);
			placeList = (ListView) view.findViewById(R.id.placeList);
			placeList.setAdapter(adapter);
			placeList.setOnItemClickListener(this);
		} else if (locationManager
				.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
			Location lastKnown = locationManager
					.getLastKnownLocation(LocationManager.GPS_PROVIDER);
			Bundle locBundle = new Bundle();

			locBundle.putDouble("lat", lastKnown.getLatitude());
			locBundle.putDouble("lon", lastKnown.getLongitude());

			GetFSVenuesTask fsVenuesTask = new GetFSVenuesTask();
			fsVenuesTask.execute(locBundle);

			GetGooglePlaces getGooglePlaces = new GetGooglePlaces();
			getGooglePlaces.execute(locBundle);

			userLoc = new Location("");
			userLoc.setLatitude(lastKnown.getLatitude());
			userLoc.setLongitude(lastKnown.getLongitude());
			places = new ArrayList<Place>();

			try {
				places = getGooglePlaces.get();
			} catch (InterruptedException e) {
			} catch (ExecutionException e) {
			}
			ArrayAdapter<Place> adapter = new PlaceAdapter(parentActivity,
					R.layout.menu_item, places, userLoc);
			placeList = (ListView) view.findViewById(R.id.placeList);
			placeList.setAdapter(adapter);
			placeList.setOnItemClickListener(this);
		} else {
			Toast.makeText(
					parentActivity,
					parentActivity.getResources().getString(
							R.string.enable_provider), Toast.LENGTH_SHORT)
					.show();
		}

		getFBPlaces();
		return view;
	}

	private void getFBPlaces() {
		Log.d("user location", String.valueOf(userLoc.getLatitude()) + ":"
				+ String.valueOf(userLoc.getLongitude()));
		Session.openActiveSession(parentActivity, true, new StatusCallback() {

			@Override
			public void call(Session session, SessionState state,
					Exception exception) {
				if (session != null && session.isOpened()) {
					Request.newPlacesSearchRequest(Session.getActiveSession(),
							userLoc, WIIConsts.NEARBY_PLACES_AREA_SIZE,
							WIIConsts.MAX_PLACE_QUANTITY, null,
							new Request.GraphPlaceListCallback() {

								@Override
								public void onCompleted(
										List<GraphPlace> places,
										Response response) {
									Log.d("fb json", places.toString());
								}

							}).executeAsync();
				}

			}
		});
	}

	@Override
	public void onLocationChanged(Location location) {
		locationManager.removeUpdates(this);

		userLoc = location;

		Bundle locBundle = new Bundle();

		locBundle.putDouble("lat", location.getLatitude());
		locBundle.putDouble("lon", location.getLongitude());

		GetGooglePlaces getGooglePlaces = new GetGooglePlaces();
		getGooglePlaces.execute(locBundle);

		GetFSVenuesTask fsVenuesTask = new GetFSVenuesTask();
		fsVenuesTask.execute(locBundle);

		places = new ArrayList<Place>();

		try {
			places = getGooglePlaces.get();
		} catch (InterruptedException e) {
		} catch (ExecutionException e) {
		}
		ArrayAdapter<Place> adapter = new PlaceAdapter(parentActivity,
				R.layout.menu_item, places, location);
		placeList = (ListView) view.findViewById(R.id.placeList);
		placeList.setAdapter(adapter);
		placeList.setOnItemClickListener(this);

	}

	@Override
	public void onStatusChanged(String provider, int status, Bundle extras) {

	}

	@Override
	public void onProviderEnabled(String provider) {

	}

	@Override
	public void onProviderDisabled(String provider) {

	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position,
			long id) {
		Log.d("placeName", places.get(position).getPlaceName());
		((CameraFragment) ((MainActivity) getActivity()).getFragmentManager()
				.findFragmentByTag(CAM_FRAG_TAG)).setPlaceNameText(places.get(
				position).getPlaceName());

		((CameraFragment) ((MainActivity) getActivity()).getFragmentManager()
				.findFragmentByTag(CAM_FRAG_TAG)).setCoord(places.get(position)
				.getPlaceLocation());

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		Session.getActiveSession().onActivityResult(parentActivity,
				requestCode, resultCode, data);
		uiHelper.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public void call(Session session, SessionState state, Exception exception) {
		onSessionStateChange(session, state, exception);
	}

	private void onSessionStateChange(Session session, SessionState state,
			Exception exception) {
		if (session != null && session.isOpened()) {
			Request.newPlacesSearchRequest(Session.getActiveSession(), userLoc,
					WIIConsts.NEARBY_PLACES_AREA_SIZE,
					WIIConsts.MAX_PLACE_QUANTITY, null,
					new Request.GraphPlaceListCallback() {

						@Override
						public void onCompleted(List<GraphPlace> places,
								Response response) {
							Log.d("fb json", places.toString());
						}

					}).executeAsync();
		} else {
		}
	}

	@Override
	public void onResume() {
		super.onResume();
		Session session = Session.getActiveSession();
		if (session != null && (session.isOpened() || session.isClosed())) {
			onSessionStateChange(session, session.getState(), null);
		}
		uiHelper.onResume();
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
		uiHelper.onDestroy();
		parentActivity = null;
	}

	@Override
	public void onPause() {
		super.onPause();
		uiHelper.onPause();
	}

	@Override
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);
		uiHelper.onSaveInstanceState(outState);
	}

}

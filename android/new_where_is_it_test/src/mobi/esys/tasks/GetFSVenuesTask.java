package mobi.esys.tasks;

import java.util.ArrayList;
import java.util.List;

import mobi.esys.constants.WIIConsts;
import mobi.esys.datatypes.Place;
import android.location.Location;
import android.os.AsyncTask;
import android.os.Bundle;

import com.urieljuliatti.foursquare.Foursquare;
import com.urieljuliatti.foursquare.models.VenuesResult;

public class GetFSVenuesTask extends AsyncTask<Bundle, Void, List<Place>> {
	private transient Foursquare foursquare = new Foursquare(
			WIIConsts.FS_CLIENT_ID, WIIConsts.FS_CLIENT_SECRET);
	private transient int area;

	@Override
	protected List<Place> doInBackground(Bundle... params) {
		return getFSPlaces(params);
	}

	private List<Place> getFSPlaces(Bundle... params) {
		area = WIIConsts.NEARBY_PLACES_AREA_SIZE;
		VenuesResult result = null;
		List<Place> places = new ArrayList<Place>();
		try {
			result = fsPlacesRequest(params);

		} catch (Exception e) {
		}
		saveDataToList(result, places);

		return places;
	}

	private VenuesResult fsPlacesRequest(Bundle... params) throws Exception {
		VenuesResult result;
		result = foursquare.getVenues("", area, params[0].getDouble("lat"),
				params[0].getDouble("lon"));
		while (result.getVenues().size() < WIIConsts.MAX_PLACE_QUANTITY) {
			result = foursquare.getVenues("", area, params[0].getDouble("lat"),
					params[0].getDouble("lon"));
			area = area + 100;
		}
		return result;
	}

	private void saveDataToList(VenuesResult result, List<Place> places) {
		for (int i = 0; i < result.getVenues().size(); i++) {
			Location placeLoc = new Location("");

			placeLoc.setLatitude(result.getVenues().get(i).getLocation()
					.getLat());
			placeLoc.setLongitude(result.getVenues().get(i).getLocation()
					.getLng());

			places.add(new Place(result.getVenues().get(i).getName(), result
					.getVenues().get(i).getAddress(), placeLoc));
		}
	}
}

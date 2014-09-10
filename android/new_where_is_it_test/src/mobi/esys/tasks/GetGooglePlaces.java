package mobi.esys.tasks;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import mobi.esys.constants.WIIConsts;
import mobi.esys.datatypes.Place;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.location.Location;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;

import com.squareup.okhttp.OkHttpClient;
import com.squareup.okhttp.Request;
import com.squareup.okhttp.Response;

public class GetGooglePlaces extends AsyncTask<Bundle, Void, List<Place>> {

	@Override
	protected List<Place> doInBackground(Bundle... params) {
		List<Place> places = new ArrayList<Place>();
		JSONObject gpOBJ = doJSONGetRequesOKHTTP(WIIConsts.GP_API_URL_PREFIX
				+ String.valueOf(params[0].getDouble("lat")) + ","
				+ String.valueOf(params[0].getDouble("lon")) + "&radius="
				+ WIIConsts.NEARBY_PLACES_AREA_SIZE + "&sensor=true&key="
				+ WIIConsts.GP_API_KEY + WIIConsts.GP_API_LANG);
		Log.d("google places", gpOBJ.toString());
		JSONArray googlePlacesArray = new JSONArray();
		try {
			googlePlacesArray = gpOBJ.getJSONArray("results");
			for (int i = 0; i < googlePlacesArray.length(); i++) {
				JSONObject placeObj = googlePlacesArray.getJSONObject(i);
				Location gpLocation = new Location("");
				gpLocation.setLatitude(Double.parseDouble(placeObj
						.getJSONObject("geometry").getJSONObject("location")
						.getString("lat")));
				gpLocation.setLongitude(Double.parseDouble(placeObj
						.getJSONObject("geometry").getJSONObject("location")
						.getString("lng")));
				places.add(new Place(placeObj.getString("name"), placeObj
						.getString("vicinity"), gpLocation));
			}
		} catch (JSONException e) {
		}
		Log.d("g places list", places.toString());
		return places;
	}

	public JSONObject doJSONGetRequesOKHTTP(String requestURL) {
		Log.d("url", requestURL);
		JSONObject jsonObject = new JSONObject();
		try {
			OkHttpClient client = new OkHttpClient();
			Request request = new Request.Builder().url(requestURL).build();
			Response response = client.newCall(request).execute();
			jsonObject = new JSONObject(response.body().string());
		} catch (IOException e) {
		} catch (JSONException e) {
		}
		Log.d("jsonObject", jsonObject.toString());
		return jsonObject;
	}

}

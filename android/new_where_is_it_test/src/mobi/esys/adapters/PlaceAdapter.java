package mobi.esys.adapters;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import mobi.esys.datatypes.Place;
import mobi.esys.where3.R;
import android.content.Context;
import android.location.Location;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

public class PlaceAdapter extends ArrayAdapter<Place> {
	private transient List<Place> places;
	private transient Location userLoc;
	private transient LayoutInflater inflater;
	private transient MenuHolder holder;

	public PlaceAdapter(Context context, int resource, List<Place> places,
			Location userLoc) {
		super(context, resource);
		this.places = places;
		this.userLoc = userLoc;
		this.inflater = ((LayoutInflater) context.getApplicationContext()
				.getSystemService(Context.LAYOUT_INFLATER_SERVICE));
	}

	@Override
	public int getCount() {
		return places.size();
	}

	@Override
	public Place getItem(int position) {
		return places.get(position);
	}

	@Override
	public long getItemId(int position) {
		return places.get(position).hashCode();
	}

	public View getView(int position, View convertView, ViewGroup parent) {
		View menuView = convertView;

		if (menuView == null) {
			menuView = this.inflater.inflate(R.layout.menu_item, parent, false);
		}

		sortByName(false);

		setHolder(position, menuView);

		return menuView;
	}

	private void setHolder(int position, View menuView) {
		holder = new MenuHolder();
		holder.menuText = (TextView) menuView.findViewById(R.id.menuItemText);
		holder.menuText.setText(places.get(position).getPlaceName()
				+ " "
				+ String.valueOf(Math.round(userLoc.distanceTo(places.get(
						position).getPlaceLocation()))) + " ì");
		menuView.setTag(holder);
	}

	private void sortByName(final boolean isOrder) {

		Collections.sort(places, new Comparator<Place>() {

			@Override
			public int compare(Place lhs, Place rhs) {
				int order_multiplier = 1;
				if (!isOrder) {
					order_multiplier = -1;
				}
				return order_multiplier
						* lhs.getPlaceName().compareTo(rhs.getPlaceName());
			}

		});
	}

	@SuppressWarnings("unused")
	private void sortByDistance(final boolean isOrder,
			final Location distLocation) {
		Collections.sort(places, new Comparator<Place>() {
			public int compare(Place lhs, Place rhs) {
				int order_multiplier = 1;
				if (!isOrder) {
					order_multiplier = -1;
				}
				int koff = -1;
				if (distLocation.distanceTo(lhs.getPlaceLocation()) > userLoc
						.distanceTo(rhs.getPlaceLocation())) {
					koff = 1;
				} else if (distLocation.distanceTo(lhs.getPlaceLocation()) == userLoc
						.distanceTo(rhs.getPlaceLocation())) {
					koff = 0;
				}
				return order_multiplier * koff;
			}
		});
	}

	static class MenuHolder {
		private transient TextView menuText;
	}
}

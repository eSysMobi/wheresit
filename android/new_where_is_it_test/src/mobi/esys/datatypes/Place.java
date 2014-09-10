/**
 * 
 */
package mobi.esys.datatypes;

import android.location.Location;

/**
 * @author Артем
 *
 */
public class Place {
	private String placeName;
	private String placeAdress;
	private Location placeLocation;

	/**
	 * 
	 */
	public Place() {
		super();
	}

	public Place(String placeName, String placeAdress, Location placeLocation) {
		super();
		this.placeName = placeName;
		this.placeAdress = placeAdress;
		this.placeLocation = placeLocation;
	}

	public Place(Place place) {
		super();
		this.placeName = place.placeName;
		this.placeAdress = place.placeAdress;
		this.placeLocation = place.placeLocation;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((placeAdress == null) ? 0 : placeAdress.hashCode());
		result = prime * result
				+ ((placeLocation == null) ? 0 : placeLocation.hashCode());
		result = prime * result
				+ ((placeName == null) ? 0 : placeName.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Place other = (Place) obj;
		if (placeAdress == null) {
			if (other.placeAdress != null)
				return false;
		} else if (!placeAdress.equals(other.placeAdress))
			return false;
		if (placeLocation == null) {
			if (other.placeLocation != null)
				return false;
		} else if (!placeLocation.equals(other.placeLocation))
			return false;
		if (placeName == null) {
			if (other.placeName != null)
				return false;
		} else if (!placeName.equals(other.placeName))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "Place [placeName=" + placeName + ", placeAdress=" + placeAdress
				+ ", placeLocation=" + placeLocation + "]";
	}

	public String getPlaceName() {
		return placeName;
	}

	public void setPlaceName(String placeName) {
		this.placeName = placeName;
	}

	public String getPlaceAdress() {
		return placeAdress;
	}

	public void setPlaceAdress(String placeAdress) {
		this.placeAdress = placeAdress;
	}

	public Location getPlaceLocation() {
		return placeLocation;
	}

	public void setPlaceLocation(Location placeLocation) {
		this.placeLocation = placeLocation;
	}

}

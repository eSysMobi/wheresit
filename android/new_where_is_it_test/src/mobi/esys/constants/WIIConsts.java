package mobi.esys.constants;

import android.os.Environment;

public class WIIConsts {
	public static final String SD_CARD_PATH = Environment
			.getExternalStorageDirectory().getAbsolutePath();

	public static final String WII_PREF = "wiiPref";
	public static final String WII_FOLDER = "WHEREISITPICTURE";
	public static final String PHOTO_FILE_PREFIX = "where";

	public static final String FS_CLIENT_ID = "0MNBWDKFGMQBK4YRMAGYRXEN3DO1VGK2ER55SNMPHZG0G1Y2";
	public static final String FS_CLIENT_SECRET = "CX2FRCTEHMG35PK3OKSHVCA3J4FX3HETLKMO1SPCC3NI0RUN";

	public static final String GP_API_KEY = "AIzaSyAdQ36ENWFZxOYFDDeV2UHZfcrdtSwfMsE";
	public static final String GP_API_URL_PREFIX = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=";
	public static final String GP_API_LANG = "&language=ru";

	public static final String CAMERA_FRAGMENT_TAG = "CamFrag";

	public static final int PICK_PICTURE_CODE = 100;
	public static final int ROTATE_PICTURE_ANGLE = 90;
	public static final int JPEG_QUALITY = 70;
	public static final int PICTURE_SIZE = 100;
	public static final int PICTURE_ZOOM = 17;
	public static final int ROUTE_LINE_WIDTH = 4;
	public static final int NEARBY_PLACES_AREA_SIZE = 300;
	public static final int MAX_PLACE_QUANTITY = 20;
}

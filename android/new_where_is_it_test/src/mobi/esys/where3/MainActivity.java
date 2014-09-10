package mobi.esys.where3;

import mobi.esys.constants.WIIConsts;
import mobi.esys.fragments.CameraFragment;
import mobi.esys.fragments.MenuFragment;
import mobi.esys.fragments.PictureFragment;
import mobi.esys.fragments.WIIMapFragment;
import android.annotation.SuppressLint;
import android.app.Fragment;
import android.app.FragmentManager;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.WindowManager;

import com.jeremyfeinstein.slidingmenu.lib.SlidingMenu;
import com.jeremyfeinstein.slidingmenu.lib.app.SlidingFragmentActivity;

@SuppressLint("NewApi")
public class MainActivity extends SlidingFragmentActivity {
	private transient SharedPreferences prefs;
	private transient int measuredWidth = 0;
	private transient int measuredHeight = 0;
	private transient float screenDensity = 0.0f;
	private transient Fragment cameraFragment;
	private transient Fragment wiiiMapFragment;
	private transient Fragment pictureFragment;
	private transient Fragment menuFragment;
	private transient FragmentManager fragmentManager;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		setBehindContentView(R.layout.activity_menu_layout);

		init();

	}

	private void init() {
		prefs = getSharedPreferences(WIIConsts.WII_PREF, MODE_PRIVATE);
		initFragment();
		getDisplaySpecs();
		initSlidingMenu();
		callMenuFragment();
		callCameraFragment();
	}

	private void initSlidingMenu() {
		final SlidingMenu slidingMenu = getSlidingMenu();
		slidingMenu.setBehindOffset(measuredWidth / 2);
		slidingMenu.setFadeDegree(0.35f);
		slidingMenu.setMode(SlidingMenu.LEFT);
		slidingMenu.setTouchModeAbove(SlidingMenu.TOUCHMODE_NONE);
	}

	private void callMenuFragment() {
		fragmentManager.beginTransaction()
				.replace(R.id.menuCnt, menuFragment, "menuFrag").commit();
	}

	@SuppressWarnings("deprecation")
	private void getDisplaySpecs() {
		Point size = new Point();
		WindowManager w = getWindowManager();

		screenDensity = getResources().getDisplayMetrics().density;

		Log.d("sd", String.valueOf(screenDensity));

		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR2) {
			w.getDefaultDisplay().getSize(size);
			measuredWidth = size.x;
			measuredHeight = size.y;
		} else {
			Display d = w.getDefaultDisplay();
			measuredWidth = d.getWidth();
			measuredHeight = d.getHeight();

		}

		Editor editor = prefs.edit();
		editor.putString("sh", String.valueOf(measuredHeight));
		editor.putString("sw", String.valueOf(measuredWidth));
		editor.putString("sd", String.valueOf(screenDensity));
		editor.commit();
	}

	private void callCameraFragment() {
		if (fragmentManager.findFragmentByTag("CamFrag") == null) {
			fragmentManager.beginTransaction()
					.replace(R.id.frmCont, cameraFragment, "CamFrag").commit();
			cameraFragment.setRetainInstance(true);
		}
	}

	private void initFragment() {
		fragmentManager = getFragmentManager();
		cameraFragment = new CameraFragment();
		wiiiMapFragment = new WIIMapFragment();
		pictureFragment = new PictureFragment();
		menuFragment = new MenuFragment();
	}

	public void callPictureFragment(Bitmap picture, String filePath) {
		Bundle pictureFragParams = new Bundle();
		pictureFragParams.putParcelable("pic", picture);
		pictureFragParams.putString("picFile", filePath);
		pictureFragment.setArguments(pictureFragParams);
		pictureFragment.setRetainInstance(true);
		fragmentManager.beginTransaction()
				.replace(R.id.frmCont, pictureFragment).commit();
	}

	public void callMapFragment(String filePath) {
		Bundle mapFragParams = new Bundle();
		mapFragParams.putString("picFile", filePath);
		wiiiMapFragment.setArguments(mapFragParams);
		wiiiMapFragment.setRetainInstance(true);
		fragmentManager.beginTransaction()
				.replace(R.id.frmCont, wiiiMapFragment).commit();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
	}

}

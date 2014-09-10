package mobi.esys.fragments;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.channels.AsynchronousCloseException;
import java.nio.channels.ClosedByInterruptException;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.FileChannel;
import java.nio.channels.NonReadableChannelException;
import java.nio.channels.NonWritableChannelException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import mobi.esys.constants.WIIConsts;
import mobi.esys.where3.MainActivity;
import mobi.esys.where3.R;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Fragment;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.hardware.Camera;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.PictureCallback;
import android.hardware.Camera.PreviewCallback;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

public class CameraFragment extends Fragment implements Callback,
		OnClickListener, PreviewCallback, PictureCallback, AutoFocusCallback,
		LocationListener {
	private static final String CPF_TAG = "cpf";
	private static final String DIR_PATH = WIIConsts.SD_CARD_PATH
			+ File.separator + WIIConsts.WII_FOLDER;
	private transient Camera camera;
	private transient SurfaceHolder holder;
	private transient LocationManager locationManager;
	private transient SurfaceView surface;
	private transient View view;
	private transient static double photoLon;
	private transient static double photoLat;
	private transient File photoFile;

	private transient Activity parentActivity;

	private transient List<Camera.Size> resolutions;

	private transient ImageView galleryBtn;
	private transient ImageView cameraBtn;
	private transient ImageView placesBtn;

	private static final int PICK_PHOTO = WIIConsts.PICK_PICTURE_CODE;
	private static final int ROTATE_ANGLE = WIIConsts.ROTATE_PICTURE_ANGLE;
	private static final int JPEG_QUALITY = WIIConsts.JPEG_QUALITY;

	private transient String formatedDate;

	private transient static AlertDialog exifDialog;

	private transient static float[] selectedImageLoc;
	private byte[] siBytes;

	private transient TextView placeNameText;

	@SuppressWarnings("deprecation")
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		view = inflater.inflate(R.layout.fragment_camera, container, false);
		parentActivity = getActivity();

		placeNameText = (TextView) view.findViewById(R.id.placeNameText);

		selectedImageLoc = new float[2];

		Date date = Calendar.getInstance().getTime();
		SimpleDateFormat formatter = new SimpleDateFormat("kkmmssddMMyyyy",
				Locale.getDefault());
		formatedDate = formatter.format(date);
		System.out.println("Today : " + formatedDate);

		parentActivity
				.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

		surface = (SurfaceView) view.findViewById(R.id.cameraSurface);
		locationManager = (LocationManager) parentActivity
				.getSystemService(Context.LOCATION_SERVICE);

		galleryBtn = (ImageView) view.findViewById(R.id.galleryBtn);
		cameraBtn = (ImageView) view.findViewById(R.id.camBtn);
		placesBtn = (ImageView) view.findViewById(R.id.placesBtn);

		cameraBtn.setOnClickListener(this);
		galleryBtn.setOnClickListener(this);
		placesBtn.setOnClickListener(this);

		holder = surface.getHolder();
		holder.addCallback(this);
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.HONEYCOMB) {
			holder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
		}

		Criteria criteria = new Criteria();

		locationManager.requestLocationUpdates(
				locationManager.getBestProvider(criteria, true), 0, 0, this);

		if (locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {
			Log.d("provider", LocationManager.NETWORK_PROVIDER);
			Location lastKnown = locationManager
					.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
			photoLat = lastKnown.getLatitude();
			photoLon = lastKnown.getLongitude();
			Log.d("photo location", photoLat + ":" + photoLon);
		} else if (!locationManager
				.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
				&& locationManager
						.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
			Log.d("provider", LocationManager.GPS_PROVIDER);
			Location lastKnown = locationManager
					.getLastKnownLocation(LocationManager.GPS_PROVIDER);
			photoLat = lastKnown.getLatitude();
			photoLon = lastKnown.getLongitude();
			Log.d("photo location", photoLat + ":" + photoLon);
		} else {
			Toast.makeText(
					parentActivity,
					parentActivity.getResources().getString(
							R.string.enable_provider), Toast.LENGTH_SHORT)
					.show();
		}
		return view;
	}

	@Override
	public void onLocationChanged(Location location) {
		photoLat = location.getLatitude();
		photoLon = location.getLongitude();
		Log.d("photo location", photoLat + ":" + photoLon);
		locationManager.removeUpdates(this);
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
	public void onAutoFocus(boolean success, Camera camera) {
		if (success) {
			Log.d("picture taken", "success");
			camera.takePicture(null, null, null, this);
		}
	}

	@Override
	public void onPictureTaken(byte[] data, Camera camera) {

		camera.startPreview();

		photoFile = new File(DIR_PATH, WIIConsts.PHOTO_FILE_PREFIX
				+ formatedDate + ".jpg");
		try {
			if (!photoFile.exists()) {
				photoFile.createNewFile();
			}

		} catch (Exception e) {

		}

		SaveInBackgroundTask background = new SaveInBackgroundTask(
				getActivity(), this, formatedDate);
		background.execute(data);
	}

	private static void saveToExif(String filePath) throws IOException {
		Log.d("exif location", photoLat + ":" + photoLon);
		double alat = Math.abs(photoLat);
		String dms = Location.convert(alat, Location.FORMAT_SECONDS);
		String[] splits = dms.split(":");
		String[] secnds = (splits[2]).split("\\.");
		String seconds;
		if (secnds.length == 0) {
			seconds = splits[2];
		} else {
			seconds = secnds[0];
		}
		ExifInterface exif = new ExifInterface(filePath);
		String latitudeStr = splits[0] + "/1," + splits[1] + "/1," + seconds
				+ "/1";
		exif.setAttribute(ExifInterface.TAG_GPS_LATITUDE, latitudeStr);

		exif.setAttribute(ExifInterface.TAG_GPS_LATITUDE_REF,
				photoLat > 0 ? "N" : "S");

		double alon = Math.abs(photoLon);

		dms = Location.convert(alon, Location.FORMAT_SECONDS);
		splits = dms.split(":");
		secnds = (splits[2]).split("\\.");

		if (secnds.length == 0) {
			seconds = splits[2];
		} else {
			seconds = secnds[0];
		}
		String longitudeStr = splits[0] + "/1," + splits[1] + "/1," + seconds
				+ "/1";

		exif.setAttribute(ExifInterface.TAG_GPS_LONGITUDE, longitudeStr);
		exif.setAttribute(ExifInterface.TAG_GPS_LONGITUDE_REF,
				photoLon > 0 ? "E" : "W");

		exif.saveAttributes();
	}

	@Override
	public void onPreviewFrame(byte[] data, Camera camera) {

	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.camBtn:
			camera.autoFocus(CameraFragment.this);
			break;
		case R.id.galleryBtn:
			startPickImageAction();
			break;
		case R.id.placesBtn:
			((MainActivity) parentActivity).getSlidingMenu().toggle();
			break;
		default:
			break;
		}
	}

	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		try {
			if (camera != null && holder != null) {
				camera.setPreviewDisplay(holder);
				camera.setPreviewCallback(this);
			} else {
				parentActivity.finish();
			}

		} catch (IOException e) {
		}

		LayoutParams layoutParams = surface.getLayoutParams();
		Camera.Parameters parameters = camera.getParameters();
		resolutions = parameters.getSupportedPictureSizes();
		int currentInt = android.os.Build.VERSION.SDK_INT;

		if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
			if (currentInt != 7) {
				camera.setDisplayOrientation(ROTATE_ANGLE);
			} else {
				Log.d("System out", "Portrait " + currentInt);

				parameters.setRotation(ROTATE_ANGLE);

				camera.setParameters(parameters);
			}
		}
		if (getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
			if (currentInt != 7) {
				camera.setDisplayOrientation(0);
			} else {
				Log.d("System out", "Landscape " + currentInt);
				parameters.set("orientation", "landscape");
				parameters.set("rotation", ROTATE_ANGLE);
				camera.setParameters(parameters);
			}
		}

		parameters.set("jpeg-quality", JPEG_QUALITY);
		resolutions = parameters.getSupportedPictureSizes();
		parameters.setPictureSize(
				resolutions.get(resolutions.size() - 1).width,
				resolutions.get(resolutions.size() - 1).height);
		camera.setParameters(parameters);

		surface.setLayoutParams(layoutParams);
		camera.startPreview();
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {

	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {

	}

	@Override
	public void onResume() {
		super.onResume();
		camera = Camera.open();
	}

	@Override
	public void onPause() {
		super.onPause();
		releaseCamera();
	}

	private void releaseCamera() {
		if (camera != null) {
			camera.setPreviewCallback(null);
			camera.stopPreview();
			camera.release();
			camera = null;
		}
		locationManager.removeUpdates(this);
	}

	static class SaveInBackgroundTask extends AsyncTask<byte[], String, String> {
		private transient Context context;
		private transient Bitmap resultBitmap;
		private transient CameraFragment cameraFragment;
		private transient ProgressDialog dialog;
		private transient File bitmapFile;
		private transient String formatDate;

		public SaveInBackgroundTask(Context context,
				CameraFragment cameraFragment, String formatDate) {
			this.context = context;
			this.cameraFragment = cameraFragment;
			this.dialog = new ProgressDialog(context);
			this.formatDate = formatDate;
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			this.dialog.setMessage(context
					.getString(R.string.waiting_for_photo));
			this.dialog.show();
		}

		@Override
		protected String doInBackground(byte[]... params) {
			cameraFragment.releaseCamera();
			try {
				File saveDir = new File(DIR_PATH);
				if (!saveDir.exists()) {
					saveDir.mkdirs();
				}
				Bitmap photo = BitmapFactory.decodeByteArray(params[0], 0,
						params[0].length);

				bitmapFile = new File(DIR_PATH + File.separator
						+ WIIConsts.PHOTO_FILE_PREFIX + formatDate + ".jpg");

				if (context.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
					Matrix matrix = new Matrix();
					matrix.postRotate(ROTATE_ANGLE);

					Bitmap rotatedBitmap = Bitmap.createBitmap(photo, 0, 0,
							photo.getWidth(), photo.getHeight(), matrix, true);

					resultBitmap = rotatedBitmap;

					bitmapFile = new File(DIR_PATH, WIIConsts.PHOTO_FILE_PREFIX
							+ formatDate + ".jpg");

					ByteArrayOutputStream bos = new ByteArrayOutputStream();
					resultBitmap.compress(CompressFormat.JPEG, JPEG_QUALITY,
							bos);
					byte[] bitmapdata = bos.toByteArray();

					FileOutputStream fos = new FileOutputStream(bitmapFile);
					fos.write(bitmapdata);
					fos.close();

				}

				else {
					Matrix matrix = new Matrix();
					matrix.postRotate(ROTATE_ANGLE * 0);

					Bitmap rotatedBitmap = Bitmap.createBitmap(photo, 0, 0,
							photo.getWidth(), photo.getHeight(), matrix, true);

					resultBitmap = rotatedBitmap;

					ByteArrayOutputStream bos = new ByteArrayOutputStream();
					resultBitmap.compress(CompressFormat.JPEG, JPEG_QUALITY,
							bos);
					byte[] bitmapdata = bos.toByteArray();

					FileOutputStream fos = new FileOutputStream(bitmapFile);
					fos.write(bitmapdata);
					fos.close();

				}

				saveToExif(bitmapFile.getCanonicalPath());

			} catch (Exception e) {

			}

			return (null);

		}

		@Override
		protected void onPostExecute(String result) {
			super.onPostExecute(result);
			if (dialog.isShowing()) {
				dialog.dismiss();
			}
			callPictureFragment(context, resultBitmap, bitmapFile);
		}

	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		switch (requestCode) {
		case PICK_PHOTO:
			if (resultCode == Activity.RESULT_OK) {
				Uri selectedImage = data.getData();
				InputStream imageStream;
				try {

					String[] filePathColumn = { MediaStore.Images.Media.DATA };

					Cursor cursor = parentActivity.getContentResolver().query(
							selectedImage, filePathColumn, null, null, null);
					cursor.moveToFirst();

					int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
					String filePath = cursor.getString(columnIndex);

					Log.d("selected file path", filePath);

					final ExifInterface exifInterface = new ExifInterface(
							filePath);
					exifInterface.getLatLong(selectedImageLoc);

					final File selectedFile = new File(filePath);

					Log.d("selected file exif geo tag",
							String.valueOf(selectedImageLoc[0]) + ":"
									+ String.valueOf(selectedImageLoc[1]));
					cursor.close();

					imageStream = getActivity().getContentResolver()
							.openInputStream(selectedImage);
					final Bitmap selectedImageBitmap = BitmapFactory
							.decodeStream(imageStream);

					ByteArrayOutputStream bos = new ByteArrayOutputStream();
					selectedImageBitmap.compress(Bitmap.CompressFormat.JPEG,
							JPEG_QUALITY, bos);
					siBytes = bos.toByteArray();

					AlertDialog.Builder ad;
					ad = new AlertDialog.Builder(parentActivity);
					ad.setMessage(parentActivity.getResources().getString(
							R.string.not_empty_geotag)); // сообщение
					ad.setPositiveButton("Да",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int arg1) {

									SaveInBackgroundTask backgroundTask = new SaveInBackgroundTask(
											parentActivity,
											CameraFragment.this, formatedDate);
									backgroundTask.execute(siBytes);
									if (exifDialog.isShowing()) {
										exifDialog.dismiss();
									}
								}
							});
					ad.setNegativeButton("Нет",
							new DialogInterface.OnClickListener() {
								public void onClick(DialogInterface dialog,
										int arg1) {
									File bitmapFile = new File(DIR_PATH,
											WIIConsts.PHOTO_FILE_PREFIX
													+ formatedDate + ".jpg");

									copyFile(selectedFile, bitmapFile);

									callPictureFragment(parentActivity,
											selectedImageBitmap, bitmapFile);
									if (exifDialog.isShowing()) {
										exifDialog.dismiss();
									}
								}
							});
					ad.setCancelable(false);
					exifDialog = ad.create();

					if (selectedImageLoc[0] != 0.0f
							&& selectedImageLoc[1] != 0.0f) {
						if (exifDialog != null && !exifDialog.isShowing()) {
							ad.show();
						}
					}

					else {
						SaveInBackgroundTask backgroundTask = new SaveInBackgroundTask(
								parentActivity, CameraFragment.this,
								formatedDate);
						backgroundTask.execute(siBytes);
					}

				} catch (FileNotFoundException e) {
				} catch (IOException e) {
				}

			} else {

			}
		}
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
	}

	private void startPickImageAction() {
		Intent photoPickerIntent = new Intent(Intent.ACTION_PICK);
		photoPickerIntent.setType("image/*");
		startActivityForResult(photoPickerIntent, PICK_PHOTO);
	}

	public void setCoord(Location location) {
		locationManager.removeUpdates(this);
		photoLat = location.getLatitude();
		photoLon = location.getLongitude();
	}

	private static void callPictureFragment(Context context,
			Bitmap resultBitmap, File bitmapFile) {

		Bitmap photoBitmap = Bitmap.createScaledBitmap(resultBitmap, 700, 1000,
				true);
		((MainActivity) context).callPictureFragment(photoBitmap,
				bitmapFile.getAbsolutePath());
	}

	public boolean copyFile(File src, File dst) {
		boolean returnValue = true;

		FileChannel inChannel = null, outChannel = null;

		try {

			inChannel = new FileInputStream(src).getChannel();
			outChannel = new FileOutputStream(dst).getChannel();

		} catch (FileNotFoundException fnfe) {

			Log.d(CPF_TAG, "inChannel/outChannel FileNotFoundException");
			fnfe.printStackTrace();
			return false;
		}

		try {
			inChannel.transferTo(0, inChannel.size(), outChannel);

		} catch (IllegalArgumentException iae) {

			Log.d(CPF_TAG, "TransferTo IllegalArgumentException");
			iae.printStackTrace();
			returnValue = false;

		} catch (NonReadableChannelException nrce) {

			Log.d(CPF_TAG, "TransferTo NonReadableChannelException");
			nrce.printStackTrace();
			returnValue = false;

		} catch (NonWritableChannelException nwce) {

			Log.d(CPF_TAG, "TransferTo NonWritableChannelException");
			nwce.printStackTrace();
			returnValue = false;

		} catch (ClosedByInterruptException cie) {

			Log.d(CPF_TAG, "TransferTo ClosedByInterruptException");
			cie.printStackTrace();
			returnValue = false;

		} catch (AsynchronousCloseException ace) {

			Log.d(CPF_TAG, "TransferTo AsynchronousCloseException");
			ace.printStackTrace();
			returnValue = false;

		} catch (ClosedChannelException cce) {

			Log.d(CPF_TAG, "TransferTo ClosedChannelException");
			cce.printStackTrace();
			returnValue = false;

		} catch (IOException ioe) {

			Log.d(CPF_TAG, "TransferTo IOException");
			ioe.printStackTrace();
			returnValue = false;

		} finally {

			if (inChannel != null)

				try {

					inChannel.close();
				} catch (IOException e) {
					e.printStackTrace();
				}

			if (outChannel != null)
				try {
					outChannel.close();
				} catch (IOException e) {
					e.printStackTrace();
				}

		}

		return returnValue;
	}

	public void setPlaceNameText(String text) {
		placeNameText.setVisibility(View.VISIBLE);
		placeNameText.setText(text);
	}
}

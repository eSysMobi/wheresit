package mobi.esys.fragments;

import mobi.esys.where3.MainActivity;
import mobi.esys.where3.R;
import android.app.Fragment;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore.Images;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageView;

public class PictureFragment extends Fragment implements OnClickListener {
	private transient View view;
	private transient ImageView picture;
	private transient ImageView shareBtn;
	private transient ImageView mapBtn;
	private transient Bitmap picBitmap;

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		init(inflater, container);

		return view;
	}

	private void init(LayoutInflater inflater, ViewGroup container) {
		view = inflater.inflate(R.layout.fragment_picture, container, false);
		picture = (ImageView) view.findViewById(R.id.picture);
		shareBtn = (ImageView) view.findViewById(R.id.shareBtn);
		mapBtn = (ImageView) view.findViewById(R.id.mapBtn);

		shareBtn.setOnClickListener(this);
		mapBtn.setOnClickListener(this);

		if (getArguments() != null) {
			picture.setImageBitmap(getBitmap(getArguments()));
		}

	}

	private Bitmap getBitmap(Bundle bitmapBundle) {
		return (Bitmap) bitmapBundle.getParcelable("pic");
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.shareBtn:
			share();
			break;
		case R.id.mapBtn:
			showMap();
			break;

		default:
			break;
		}

	}

	private void showMap() {
		Log.d("picFile", getArguments().getString("picFile"));
		((MainActivity) getActivity()).callMapFragment(getArguments()
				.getString("picFile"));
	}

	private void share() {
		Intent shareIntent = new Intent(Intent.ACTION_SEND);
		shareIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_WHEN_TASK_RESET);
		shareIntent.setType("image/*");
		String pathofBmp = Images.Media.insertImage(getActivity()
				.getContentResolver(), picBitmap, "shared_photo", null);
		Uri bmpUri = Uri.parse(pathofBmp);
		shareIntent.putExtra(Intent.EXTRA_STREAM, bmpUri);
		startActivity(shareIntent);
	}

}

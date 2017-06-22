package com.jwkj.fragment;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import com.yoosee.R;
import com.jwkj.activity.DeviceUpdateActivity;
import com.jwkj.activity.MainControlActivity;
import com.jwkj.data.Contact;
import com.jwkj.global.Constants;
import com.p2p.core.P2PValue;

public class MainControlFrag extends BaseFragment implements OnClickListener{
	RelativeLayout time_contrl,remote_control,
				   alarm_control,video_control,
				   record_control,security_control,
				   net_control,defenceArea_control,
				   chekc_device_update,sd_card_control;
	private Context mContext;
	private Contact mContact;
	@Override
	public void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
	}
	
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		mContext = MainControlActivity.mContext;
		mContact = (Contact) getArguments().getSerializable("contact");
		View view = inflater.inflate(R.layout.fragment_control_main, container, false);
		initComponent(view);
		return view;
	}
	 
	public void initComponent(View view){
		
		time_contrl = (RelativeLayout) view.findViewById(R.id.time_control);
		remote_control = (RelativeLayout) view.findViewById(R.id.remote_control);
		alarm_control = (RelativeLayout) view.findViewById(R.id.alarm_control);
		video_control = (RelativeLayout) view.findViewById(R.id.video_control);
		record_control = (RelativeLayout) view.findViewById(R.id.record_control);
		security_control = (RelativeLayout) view.findViewById(R.id.security_control);
		net_control = (RelativeLayout) view.findViewById(R.id.net_control);
		defenceArea_control = (RelativeLayout) view.findViewById(R.id.defenceArea_control);
		chekc_device_update = (RelativeLayout) view.findViewById(R.id.check_device_update);
		sd_card_control=(RelativeLayout)view.findViewById(R.id.sd_card_control);
		defenceArea_control.setOnClickListener(this);
		net_control.setOnClickListener(this);
		security_control.setOnClickListener(this);
		record_control.setOnClickListener(this);
		video_control.setOnClickListener(this);
		time_contrl.setOnClickListener(this);
		remote_control.setOnClickListener(this);
		alarm_control.setOnClickListener(this);		
		chekc_device_update.setOnClickListener(this);
		sd_card_control.setOnClickListener(this);
		if(mContact.contactType==P2PValue.DeviceType.PHONE){
			view.findViewById(R.id.control_main_frame).setVisibility(RelativeLayout.GONE);
		}else if(mContact.contactType==P2PValue.DeviceType.NPC){
			chekc_device_update.setVisibility(RelativeLayout.GONE);
			sd_card_control.setBackgroundResource(R.drawable.tiao_bg_bottom);
		}else{
			chekc_device_update.setVisibility(RelativeLayout.VISIBLE);
			defenceArea_control.setBackgroundResource(R.drawable.tiao_bg_center);
		}
	}
	
	@Override
	public void onClick(View view) {
		// TODO Auto-generated method stub
		switch(view.getId()){
		case R.id.remote_control:
			Intent go_remote_control = new Intent();
			go_remote_control.setAction(Constants.Action.REPLACE_REMOTE_CONTROL);
			go_remote_control.putExtra("isEnforce", true);
			mContext.sendBroadcast(go_remote_control);
			break;
		case R.id.time_control:
			Intent go_time_control = new Intent();
			go_time_control.setAction(Constants.Action.REPLACE_SETTING_TIME);
			go_time_control.putExtra("isEnforce", true);
			mContext.sendBroadcast(go_time_control);
			break;
		case R.id.alarm_control:
			Intent go_alarm_control = new Intent();
			go_alarm_control.setAction(Constants.Action.REPLACE_ALARM_CONTROL);
			go_alarm_control.putExtra("isEnforce", true);
			mContext.sendBroadcast(go_alarm_control);
			break;
		case R.id.record_control:
			Intent go_record_control = new Intent();
			go_record_control.setAction(Constants.Action.REPLACE_RECORD_CONTROL);
			go_record_control.putExtra("isEnforce", true);
			mContext.sendBroadcast(go_record_control);
			break;
		case R.id.video_control:
			Intent go_video_control = new Intent();
			go_video_control.setAction(Constants.Action.REPLACE_VIDEO_CONTROL);
			go_video_control.putExtra("isEnforce", true);
			mContext.sendBroadcast(go_video_control);
			break;
		case R.id.security_control:
			Intent go_security_control = new Intent();
			go_security_control.setAction(Constants.Action.REPLACE_SECURITY_CONTROL);
			go_security_control.putExtra("isEnforce", true);
			mContext.sendBroadcast(go_security_control);
			break;
		case R.id.net_control:
			Intent go_net_control = new Intent();
			go_net_control.setAction(Constants.Action.REPLACE_NET_CONTROL);
			go_net_control.putExtra("isEnforce", true);
			mContext.sendBroadcast(go_net_control);
			break;
		case R.id.defenceArea_control:
			Intent go_da_control = new Intent();
			go_da_control.setAction(Constants.Action.REPLACE_DEFENCE_AREA_CONTROL);
			go_da_control.putExtra("isEnforce", true);
			mContext.sendBroadcast(go_da_control);
			break;
		case R.id.check_device_update:
			Intent check_update = new Intent(mContext,DeviceUpdateActivity.class);
			check_update.putExtra("contact", mContact);
			mContext.startActivity(check_update);
			break;
		case R.id.sd_card_control:
			Intent go_sd_card_control=new Intent();
		    go_sd_card_control.setAction(Constants.Action.REPLACE_SD_CARD_CONTROL);
		    go_sd_card_control.putExtra("isEnforce", true);
		    mContext.sendBroadcast(go_sd_card_control);
			break;
		}
	}
}

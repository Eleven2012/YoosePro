package com.jwkj.adapter;

import java.util.List;

import com.yoosee.R;
import com.jwkj.activity.AddContactNextActivity;
import com.jwkj.data.Contact;
import com.jwkj.entity.LocalDevice;
import com.jwkj.global.Constants;
import com.jwkj.global.FList;
import com.jwkj.global.NpcCommon;
import com.p2p.core.P2PValue;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

public class LocalDeviceListAdapter extends BaseAdapter{
	List<LocalDevice> datas;
	Context mContext;
	public LocalDeviceListAdapter(Context context){
		datas = FList.getInstance().getLocalDevices();
		this.mContext = context;
	}
	@Override
	public int getCount() {
		// TODO Auto-generated method stub
		return datas.size();
	}

	@Override
	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public View getView(int position, View arg1, ViewGroup arg2) {
		// TODO Auto-generated method stub
		View view = arg1;
		if(null==view){
			view = LayoutInflater.from(mContext).inflate(R.layout.list_item_local_device,null);
		}
		
		TextView name = (TextView) view.findViewById(R.id.text_name);
		ImageView typeImg = (ImageView) view.findViewById(R.id.img_type);
		TextView text_ip_address=(TextView)view.findViewById(R.id.text_ip_address);
		
		final LocalDevice localDevice = datas.get(position);
		name.setText(localDevice.getContactId());
		text_ip_address.setText(localDevice.address.getHostAddress());
		switch(localDevice.getType()){
		case P2PValue.DeviceType.NPC:
			typeImg.setImageResource(R.drawable.ic_device_type_npc);
			break;
		case P2PValue.DeviceType.IPC:
			typeImg.setImageResource(R.drawable.ic_device_type_ipc);
			break;
		case P2PValue.DeviceType.DOORBELL:
			typeImg.setImageResource(R.drawable.ic_device_type_door_bell);
			break;
		case P2PValue.DeviceType.UNKNOWN:
			typeImg.setImageResource(R.drawable.ic_device_type_unknown);
			break;
		default:
			typeImg.setImageResource(R.drawable.ic_device_type_unknown);
			break;
		}
		
		view.setOnClickListener(new OnClickListener(){

			@Override
			public void onClick(View arg0) {
				// TODO Auto-generated method stub
				Contact saveContact = new Contact();
				saveContact.contactId = localDevice.contactId;
				saveContact.contactType = localDevice.type;
				saveContact.messageCount = 0;
				saveContact.activeUser = NpcCommon.mThreeNum;
				String mark = localDevice.address.getHostAddress();
				Intent modify = new Intent();
				modify.setClass(mContext, AddContactNextActivity.class);
				if(localDevice.getFlag()==Constants.DeviceFlag.ALREADY_SET_PASSWORD){
					modify.putExtra("isCreatePassword", false);
				}else{
					modify.putExtra("isCreatePassword", true);
				}
				
				modify.putExtra("contact", saveContact);
				modify.putExtra("ipFlag",mark.substring(mark.lastIndexOf(".")+1, mark.length()));
				mContext.startActivity(modify);
			}
			
		});
		return view;
	}

	public void updateData(){
		FList.getInstance().updateLocalDeviceWithLocalFriends();
		this.datas = FList.getInstance().getLocalDevices();
		this.notifyDataSetChanged();
	}
}

package com.jwkj.global;


import android.app.Notification;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;

import com.jwkj.P2PConnect;
import com.jwkj.entity.Account;
import com.jwkj.thread.MainThread;
import com.p2p.core.P2PHandler;

public class MainService extends Service{
	Context context;
	@Override
	public IBinder onBind(Intent arg0) {
		// TODO Auto-generated method stub
		return null;
	}
	
	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		context=this;
		Notification notification = new Notification();
		startForeground(1, notification);
	}

	
	@Override
	public void onStart(Intent intent, int startId) {
		// TODO Auto-generated method stub
		Account account = AccountPersist.getInstance().getActiveAccountInfo(this);
		try{
			int codeStr1 = (int) Long.parseLong(account.rCode1);
			int codeStr2 = (int) Long.parseLong(account.rCode2);
			if(account!=null){
				boolean result = P2PHandler.getInstance().p2pConnect(account.three_number, codeStr1, codeStr2);
				if(result){
					new P2PConnect(getApplicationContext());
					new MainThread(context).go();
				}else{
				}
			}else{
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		super.onStart(intent, startId);
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		// TODO Auto-generated method stub
		flags = START_STICKY;
		return super.onStartCommand(intent, flags, startId);
	}
	
	
	@Override
	public void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
		MainThread.getInstance().kill();
		P2PHandler.getInstance().p2pDisconnect();
	}

}

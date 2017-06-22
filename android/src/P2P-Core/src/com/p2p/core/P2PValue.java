package com.p2p.core;

public class P2PValue {
	public static class AlarmType{
		public static final int EXTERNAL_ALARM = 1;
		public static final int MOTION_DECT_ALARM = 2;
		public static final int EMERGENCY_ALARM = 3;
		public static final int EXT_LINE_ALARM = 5;
		public static final int LOW_VOL_ALARM = 6;
		public static final int PIR_ALARM = 7;
		public static final int DEFENCE=8;
		public static final int NO_DEFENCE=9;
		public static final int BATTERY_LOW_ALARM=10;
		public static final int ALARM_TYPE_DOORBELL_PUSH=13;
		public static final int RECORD_FAILED_ALARM=15;
	}
	
	public static class	DeviceType{
		public static final int UNKNOWN = 0;
		
		public static final int NPC = 2;
		public static final int PHONE = 3;
		public static final int PC = 4;
		public static final int DOORBELL = 5;
		public static final int IPC = 7;
		
		public static final int ROBOT = 999;
	}
	
	public static class VideoMode{
		public static final int VIDEO_MODE_SD = 5;
		public static final int VIDEO_MODE_LD = 6;
		public static final int VIDEO_MODE_HD = 7;
	}
	
	public static class UpdateState{
		public static final int STATE_UPDATING = 1;
		public static final int STATE_UPDATE_SUCCESS = 65;
	}
}

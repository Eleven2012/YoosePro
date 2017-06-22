package com.jwkj.data;

import java.io.Serializable;

import com.jwkj.global.Constants;

public class Contact implements Serializable, Comparable {
	// id
	public int id;
	// 联系人名称
	public String contactName;
	// 联系人ID
	public String contactId;
	// 联系人监控密码 注意：不是登陆密码，只有当联系人类型为设备才有
	public String contactPassword;
	// 联系人类型
	public int contactType;
	// 此联系人发来多少条未读消息
	public int messageCount;
	// 当前登录的用户
	public String activeUser;
	// 在线状态 不保存数据库
	public int onLineState = Constants.DeviceState.OFFLINE;
	// 布放状态不保存数据库 
	public int defenceState = Constants.DefenceState.DEFENCE_STATE_LOADING;
	// 记录是否是点击获取布放状态 不保存数据库
	public boolean isClickGetDefenceState = false;
	// 按在线状态排序
	@Override
	public int compareTo(Object arg0) {
		// TODO Auto-generated method stub
		Contact o = (Contact) arg0;
		if (o.onLineState > this.onLineState) {
			return 1;
		} else if (o.onLineState < this.onLineState) {
			return -1;
		} else {
			return 0;
		}
	}
}

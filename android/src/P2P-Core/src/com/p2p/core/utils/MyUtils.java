package com.p2p.core.utils;

import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.p2p.core.global.Config;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

public class MyUtils {
	/*
	 * 是否是纯数字字串
	 */
	public static boolean isNumeric(String str){ 
		 if(null==str){
			 return false;
		 }
	     Pattern pattern = Pattern.compile("[0-9]*"); 
	     return pattern.matcher(str).matches(); 
	} 
	
	/*
	 * 获取CPU版本
	 */
	public static int getCPUVesion(){
		int version = 0;
		String verString = Build.CPU_ABI;
		Log.i("cpuversion", "verString"+verString);
		try {
			String ver = verString.substring(9, 10);
			if(isNumeric(ver)){
				version = Integer.parseInt(ver);
				Log.i("cpuversion", "version"+version);
			}
		} catch (Exception e) {
		}
		return version;
	}
	
	public static boolean isZh(Context context) {
        Locale locale = context.getResources().getConfiguration().locale;
        String language = locale.getLanguage();
        if (language.endsWith("zh"))
            return true;
        else
            return false;
    }
	
	public static String convertPlanTime(int time){
		int minute_to = (time&0xff);
		int minute_from = ((time>>8)&0xff);
		int hour_to = ((time>>16)&0xff);
		int hour_from = ((time>>24)&0xff);
		StringBuilder sb = new StringBuilder();
    	if(hour_from<10){
    		sb.append("0"+hour_from+":");
    	}else{
    		sb.append(hour_from+":");
    	}
    	if(minute_from<10){
    		sb.append("0"+minute_from+"-");
    	}else{
    		sb.append(minute_from+"-");
    	}
    	
    	if(hour_to<10){
    		sb.append("0"+hour_to+":");
    	}else{
    		sb.append(hour_to+":");
    	}
    	
    	if(minute_to<10){
    		sb.append("0"+minute_to);
    	}else{
    		sb.append(""+minute_to);
    	}
    	return sb.toString();
	}
	
	public static int convertPlanTime(String time){
		int iRet = 0;
		try{
			String[] times = time.split("-");
			String[] time_from = times[0].split(":");
			String[] time_to = times[1].split(":");
			
			iRet = ((Integer.parseInt(time_from[0])<<24)|
					   (Integer.parseInt(time_to[0])<<16)|
					   (Integer.parseInt(time_from[1])<<8)|
					   (Integer.parseInt(time_to[1])<<0));
			return iRet;
		}catch(Exception e){
			return iRet;
		}
		
	}
	
	public static int dip2px(Context context, int dipValue) {
		final float scale = context.getResources().getDisplayMetrics().density;
		return (int) (dipValue * scale + 0.5f);
	}
	
	public static String convertDeviceTime(int iTime){
		int year = (2000+((iTime>>24)&0x3f));
    	int month = (iTime>>18)&0x3f;
    	int day = (iTime>>12)&0x3f;
    	int hour = (iTime>>6)&0x3f;
    	int minute = (iTime>>0)&0x3f;
    	
    	
    	StringBuilder sb = new StringBuilder();
		sb.append(year+"-");
		
    	if(month<10){
    		sb.append("0"+month+"-");
    	}else{
    		sb.append(month+"-");
    	}
    	
    	if(day<10){
    		sb.append("0"+day+" ");
    	}else{
    		sb.append(day+" ");
    	}
    	
    	if(hour<10){
    		sb.append("0"+hour+":");
    	}else{
    		sb.append(hour+":");
    	}
    	
    	if(minute<10){
    		sb.append("0"+minute);
    	}else{
    		sb.append(""+minute);
    	}
    	return sb.toString();
	}
	
	public static String getBitProcessingVersion(){
		try{
			String[] parseVerson = getVersion().split("\\.");
			int a = Integer.parseInt(parseVerson[0])<<24;
			int b = Integer.parseInt(parseVerson[1])<<16;
			int c = Integer.parseInt(parseVerson[2])<<8;
			int d = Integer.parseInt(parseVerson[3]);
			return String.valueOf((a|b|c|d));
		}catch(Exception e){
			return "9999";
		}
	}
	
	public static String getVersion(){
		String version = "";
		InputStream input = MyUtils.class.getClassLoader().getResourceAsStream("version.xml");
		try {
			HashMap<String,String> data = parseXml(input);
			//获取当前版本信息
			version =  data.get("version");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if(version.equals("")){
			return Config.AppConfig.VERSION;
		}
		return version;
	}
	
	public static long convertTimeStringToInterval(String time) {
		long interval = 0;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
		Date d;
		try {

			d = sdf.parse(time);
			interval = d.getTime();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return interval;
	}

	/*
	 * 读取version.xml版本信息
	 */
	private static HashMap<String,String> parseXml(InputStream input) throws Exception{
		HashMap<String, String> hashMap = new HashMap<String, String>();
		
		// 实例化一个文档构建器工厂
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		// 通过文档构建器工厂获取一个文档构建器
		DocumentBuilder builder = factory.newDocumentBuilder();
		// 通过文档通过文档构建器构建一个文档实例
		Document document = builder.parse(input);
		//获取XML文件根节点
		Element root = document.getDocumentElement();
		//获得所有子节点
		NodeList childNodes = root.getChildNodes();
		for (int j = 0; j < childNodes.getLength(); j++)
		{
			//遍历子节点
			Node childNode = (Node) childNodes.item(j);
			if (childNode.getNodeType() == Node.ELEMENT_NODE)
			{
				Element childElement = (Element) childNode;
				//版本号
				if ("version".equals(childElement.getNodeName()))
				{
					hashMap.put("version",childElement.getFirstChild().getNodeValue());
				}
			}
		}
		return hashMap;
	}
	
}

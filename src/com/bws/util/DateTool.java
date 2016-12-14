/*****************************************************************
 *��ȡ��ǰʱ�䣬��ʽΪyyyy-MM-dd
 *��ȡ��ǰʱ�䣬��ʽΪyyyyMM
 *��ȡ�ϸ��µĵ�ǰʱ�䣬��ʽΪyyyy-MM-dd
 *��ȡ�ϸ��µĵ�ǰʱ�䣬��ʽΪyyyyMM
 ******************************************************************/
package com.bws.util;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class DateTool {
    public DateTool() {

    }

    public static String getSeason(String month) {
        int month_n = Integer.parseInt(month);
        String season = "";
        if (month_n > 0 && month_n < 4) {
            season = "01";
        }
        if (month_n > 3 && month_n < 7) {
            season = "02";
        }
        if (month_n > 6 && month_n < 10) {
            season = "03";
        }
        if (month_n > 9 && month_n < 13) {
            season = "04";
        }
        return season;
    }

    public static String getPreSeason() throws ParseException {
        SimpleDateFormat simpleDateFormat = new
                SimpleDateFormat("yyyyMM");
        String nowMonth = simpleDateFormat.format(new Date());

        int nowSeason = Integer.parseInt(getSeason(nowMonth.substring(4, 6)));
        int preSeason = nowSeason - 1;
        String result = "";
        if (0 == preSeason) {
            result = Integer.parseInt(nowMonth.substring(0, 4)) - 1 + "04";
        } else {
            result = Integer.parseInt(nowMonth.substring(0, 4)) + "0" + String.valueOf(preSeason);
        }
        return result;
    }

    public static String getPreYear() {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy");
        String year = simpleDateFormat.format(new Date());
        String preYear = String.valueOf(Integer.parseInt(year) - 1);
        return preYear;
    }

    public static String getNowDate01() {
        Date date = new Date();
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        return df.format(date);
    }

    public static String getNowDate02() {
        Date date = new Date();
        SimpleDateFormat df = new SimpleDateFormat("yyyyMM");
        return df.format(date);
    }

    public static String getPreMonDate01() {
        Date date = new Date();
        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.add(Calendar.MONTH, -1);
        return df.format(cal.getTime());

    }

    public static String getPreMonDate02() {
        Date date = new Date();
        SimpleDateFormat df = new SimpleDateFormat("yyyyMM");
        int day = Calendar.getInstance().get(Calendar.DAY_OF_MONTH);
        Calendar cal = Calendar.getInstance();
        if (day > 15) {
            cal.setTime(date);
            cal.add(Calendar.MONTH, -1);
        } else {
            cal.setTime(date);
            cal.add(Calendar.MONTH, -2);
        }
        return df.format(cal.getTime());
    }

    public static String getPreMonDate03() {
        Date date = new Date();
        SimpleDateFormat df = new SimpleDateFormat("yyyyMM");
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);
        cal.add(Calendar.MONTH, -1);
        return df.format(cal.getTime());
    }

}
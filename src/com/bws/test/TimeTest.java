package com.bws.test;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class TimeTest {
    public static void main(String[] args) throws ParseException {
        SimpleDateFormat simpleDateFormat =
                new SimpleDateFormat("yyyy-MM");
        Date date = simpleDateFormat.parse("2016-02");

        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        int year = calendar.get(Calendar.YEAR);
        int lastMonth = calendar.get(Calendar.MONTH);
        String lastMonths = String.valueOf(lastMonth);

        if (lastMonth < 10 && lastMonth > 0) {

            lastMonths = "0" + lastMonth;
        }
        if (lastMonth == 0) {
            lastMonths = "12";
            year--;
        }

        System.out.println(String.valueOf(year) + lastMonths);
    }
}

package com.bws.test;

import java.util.Calendar;

public class TimeTest {

    public static void main(String[] args) {
        Calendar calendar = Calendar.getInstance();
        System.out.println(calendar.get(Calendar.DATE - 1));

    }

}

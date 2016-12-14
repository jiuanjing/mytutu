package com.bws.util;

import java.util.ArrayList;
import java.util.List;

/**
 * 集合类的一些工具方法
 * Created by wang on 2016/11/3.
 */
public class CollectionUtil {

    /**
     * 移除list中的重复值
     *
     * @param list
     * @return list
     */
    public static List<Object> removeDuplicateList(List<Object> list) {
        List<Object> tempList = new ArrayList<Object>();
        for (Object obj : list) {
            if (!tempList.contains(obj)) {
                tempList.add(obj);
            }
        }
        return tempList;
    }
}

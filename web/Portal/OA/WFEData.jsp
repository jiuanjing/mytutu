<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%--
  Created by wangdegang on 2016/9/4 14:40
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation dbOperation = new DBOperation(true);
    if (dbOperation.dbOpen()) {
        try {
            //0->本月 1->上月 2->本年
            String type = request.getParameter("type");

            Map<String, Object> gsonmap = new HashMap<String, Object>();
            List<String> list1 = new ArrayList<String>();
            List<String> list2 = new ArrayList<String>();

            Calendar calendar = Calendar.getInstance();
            int year = calendar.get(Calendar.YEAR);//当前年
            int lastMonth = calendar.get(Calendar.MONTH);//当前月-1

            calendar.add(Calendar.DATE, -1);
            Date date = calendar.getTime();
            String lastDay = (new SimpleDateFormat("yyyy-MM-dd").format(date));

            String lastMonths = String.valueOf(lastMonth);

            if (lastMonth < 10 && lastMonth > 0) {
                lastMonths = "0" + lastMonth;
            }
            if (lastMonth == 0) {
                lastMonths = "12";
                year--;
            }

            String sql = "";

            if ("1".equals(type)) {
                sql = "SELECT *  " +
                        "  FROM (SELECT SUM(WFE_NUM) S_NUM, T.DEPT_SHORT_NAME  " +
                        "    FROM SCNOA.OA_USER_WFE_COUNT@OA248 T  " +
                        "   WHERE SUBSTR(T.JINGB_TIME, 1, 7) = '" + String.valueOf(year) +
                        "-" + lastMonths +
                        "'  GROUP BY T.DEPT_SHORT_NAME  " +
                        "   ORDER BY S_NUM DESC)  " +
                        " WHERE ROWNUM < 11  " +
                        " ORDER BY S_NUM ASC";
            } else if ("2".equals(type)) {
                if (lastMonth == 0) {
                    year++;
                }
                sql = "SELECT *  " +
                        "  FROM (SELECT SUM(WFE_NUM) S_NUM, T.DEPT_SHORT_NAME  " +
                        "      FROM SCNOA.OA_USER_WFE_COUNT@OA248 T  " +
                        "     WHERE SUBSTR(T.JINGB_TIME, 1,4) = '" + year + "'  " +
                        "     GROUP BY T.DEPT_SHORT_NAME  " +
                        "     ORDER BY S_NUM DESC)  " +
                        " WHERE ROWNUM < 11  " +
                        " ORDER BY S_NUM ASC";
            } else if ("0".equals(type)) {
                sql = "SELECT *  " +
                        "  FROM (SELECT SUM(WFE_NUM) S_NUM, T.DEPT_SHORT_NAME  " +
                        "      FROM SCNOA.OA_USER_WFE_COUNT@OA248 T  " +
                        "     WHERE T.JINGB_TIME = '" + lastDay +
                        "'    GROUP BY T.DEPT_SHORT_NAME  " +
                        "     ORDER BY S_NUM DESC)  " +
                        " WHERE ROWNUM < 11  " +
                        " ORDER BY S_NUM ASC";
            }
//            System.out.println(sql);
            ResultSet rs = dbOperation.executeQuery(sql);
            if (null != rs) {
                try {
                    while (rs.next()) {
                        list1.add(rs.getString(1));
                        list2.add(rs.getString(2));
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            gsonmap.put("data", list1);
            gsonmap.put("name", list2);

            Gson gson = new Gson();
            String s = gson.toJson(gsonmap);
            out.write(s);
        } catch (Exception e) {
            throw e;
        } finally {
            dbOperation.dbClose();
        }
    } else {
        out.write("<script>alert('对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！');</script>");
    }
%>

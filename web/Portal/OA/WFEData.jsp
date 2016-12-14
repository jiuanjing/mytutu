<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.*" %>
<%--
  Created by wangdegang on 2016/9/4 14:40
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation dbOperation = new DBOperation(true);
    if (dbOperation.dbOpen()) {
        try {
            String type = request.getParameter("type");

            Map<String, Object> gsonmap = new HashMap<String, Object>();
            List<String> list1 = new ArrayList<String>();
            List<String> list2 = new ArrayList<String>();

            Calendar calendar = Calendar.getInstance();
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

            String sql = "";

            if ("true".equals(type)) {
                sql = "SELECT *  " +
                        "  FROM (SELECT SUM(WFE_NUM) S_NUM, T.DEPT_SHORT_NAME  " +
                        "    FROM SCNOA.OA_USER_WFE_COUNT@OA248 T  " +
                        "   WHERE SUBSTR(T.JINGB_TIME, 1, 7) = '" + String.valueOf(year) +
                        "-" + lastMonths +
                        "'  GROUP BY T.DEPT_SHORT_NAME  " +
                        "   ORDER BY S_NUM DESC)  " +
                        " WHERE ROWNUM < 11  " +
                        " ORDER BY S_NUM ASC";
            } else {
                sql = "SELECT *  " +
                        "  FROM (SELECT SUM(WFE_NUM) S_NUM, T.DEPT_SHORT_NAME  " +
                        "      FROM SCNOA.OA_USER_WFE_COUNT@OA248 T  " +
                        "     WHERE SUBSTR(T.JINGB_TIME, 1,4) = '" + year + "'  " +
                        "     GROUP BY T.DEPT_SHORT_NAME  " +
                        "     ORDER BY S_NUM DESC)  " +
                        " WHERE ROWNUM < 11  " +
                        " ORDER BY S_NUM ASC";
            }

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

<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--
  Created by wang at 2016/10/15 10:42
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String year = request.getParameter("year");
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "SELECT T1.TYPE_NAME, SUM(T.INVEST_AMOUNT)  " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE_ALL T, ECHARTS.DIM_OP_COMPANY_TYPE T1  " +
                    " WHERE T.DATE_ID =  " + year +
                    "   AND T.BU_ID = T1.TYPE_ID  " +
                    " GROUP BY T.BU_ID, T1.TYPE_NAME";
            ResultSet rs = db.executeQuery(sql);
            if (rs != null) {
                try {
                    List<Map<String, String>> dataList = new ArrayList<Map<String, String>>();
                    while (rs.next()) {
                        Map<String, String> map = new HashMap<String, String>();
                        map.put("value", rs.getString(2));
                        map.put("name", rs.getString(1));
                        dataList.add(map);
                    }
                    Gson gson = new Gson();
                    String s = gson.toJson(dataList);
                    out.write(s);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>
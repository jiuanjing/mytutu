<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    //标准饼图的数据格式
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String year = request.getParameter("year");
            String sql = "SELECT SUM(T.SCALE_WATER), " +
                    "    SUM(T.SCALE_SEWAGE), " +
                    "    SUM(T.SCALE_RECLAIMED), " +
                    "    SUM(T.SCALE_SOLID_WASTE / 10000) " +
                    "  FROM  echarts.DM_OP_YR_BASE_SCALE T " +
                    " WHERE T.DATE_ID =" + year;
            ResultSet rs = db.executeQuery(sql);
            if (rs != null) {
                try {
                    List<Map<String, String>> dataList = new ArrayList<Map<String, String>>();
                    while (rs.next()) {
                        Map<String, String> map1 = new HashMap<String, String>();
                        Map<String, String> map2 = new HashMap<String, String>();
                        Map<String, String> map3 = new HashMap<String, String>();
                        Map<String, String> map4 = new HashMap<String, String>();
                        map1.put("value", rs.getString(1));
                        map1.put("name", "供水");
                        map2.put("value", rs.getString(2));
                        map2.put("name", "污水");
                        map3.put("value", rs.getString(3));
                        map3.put("name", "再生水");
                        map4.put("value", rs.getString(4));
                        map4.put("name", "固废");
                        dataList.add(map1);
                        dataList.add(map2);
                        dataList.add(map3);
                        dataList.add(map4);
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


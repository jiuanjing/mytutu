<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation dbOperation = new DBOperation(true);
    if (dbOperation.dbOpen()) {
        try {
            String city = request.getParameter("city");
            String dept = "";
            String sql1 = "SELECT DISTINCT T2.REGION_NAME, T3.DEPT_NAME " +
                    "  FROM ECHARTS.DIM_OP_COMPANY T1, ECHARTS.DIM_REGION T2, ECHARTS.DIM_DEPT_OP T3," +
                    "   ECHARTS.DIM_CITY  T4 " +
                    " WHERE T1.REGION_ID = T2.REGION_ID AND T1.CITY_ID = T4.CITY_ID" +
                    "   AND T1.DEPT_ID = T3.DEPT_ID " +
                    "   AND T4.CITY_NAME LIKE '%" + city.substring(0, city.length() - 1) + "%'";
            ResultSet resultSet1 = dbOperation.executeQuery(sql1);
            while (resultSet1.next()) {
                dept = resultSet1.getString(2);
            }


            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
            String sql = "SELECT T.DEPT_ID, T.DEPT_NAME FROM ECHARTS.DIM_DEPT_OP T" +
                    " order by t.dept_id";
            ResultSet resultSet = dbOperation.executeQuery(sql);
            while (resultSet.next()) {
                Map<String, Object> map = new HashMap<String, Object>();
                if (dept.equals(resultSet.getString(2))) {
                    map.put("id", resultSet.getString(1));
                    map.put("text", resultSet.getString(2));
                    map.put("selected", true);
                } else {
                    map.put("id", resultSet.getString(1));
                    map.put("text", resultSet.getString(2));
                }
                list.add(map);
            }
            Gson gson = new Gson();
            String s = gson.toJson(list);
            out.write(s);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            dbOperation.dbClose();
        }
    }
%>

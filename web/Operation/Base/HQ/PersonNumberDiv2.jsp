<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %><%--
  Created by wang at 2016/10/15 10:42
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String year = request.getParameter("year");
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "SELECT SUM(T.HEADS_COUNT), T2.DEPT_NAME  " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T, ECHARTS.DIM_DEPT_OP T2  " +
                    " WHERE T.DATE_ID = ?" +
                    "   AND T.DEPT_ID = T2.DEPT_ID  " +
                    " GROUP BY T.DEPT_ID, T2.DEPT_NAME";
            PreparedStatement preparedStatement = db.getPrepareStmt(sql);
            try {
                preparedStatement.setString(1, year);
                ResultSet resultSet = preparedStatement.executeQuery();
                if (resultSet != null) {
                    Map<String, List<String>> map = new HashMap<String, List<String>>();
                    List<String> list1 = new ArrayList<String>();
                    List<String> list2 = new ArrayList<String>();
                    while (resultSet.next()) {
                        list1.add(resultSet.getString(2));
                        list2.add(resultSet.getString(1));
                    }
                    map.put("deptName", list1);
                    map.put("people", list2);
                    Gson gson = new Gson();
                    String returnData = gson.toJson(map);
                    out.write(returnData);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>
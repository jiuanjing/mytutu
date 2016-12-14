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
    year = year.length() == 0 ? "2015" : year;
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "";
            PreparedStatement preparedStatement = db.getPrepareStmt(sql);
            try {
                preparedStatement.setString(1, year);
                ResultSet resultSet = preparedStatement.executeQuery();
                if (resultSet != null) {
                    Map<String, List<String>> map = new HashMap<String, List<String>>();
                    List<String> list1 = new ArrayList<String>();
                    List<String> list2 = new ArrayList<String>();
                    while (resultSet.next()) {
                        list1.add(resultSet.getString(1));
                        list2.add(resultSet.getString(2));
                    }
                    map.put("deptName", list1);
                    map.put("quantity", list2);
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
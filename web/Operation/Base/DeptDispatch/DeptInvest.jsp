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
    String deptId = request.getParameter("deptId");
    deptId = deptId.length() == 0 ? "1" : deptId;
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "select t.date_id,  " +
                    "       sum(decode(t2.flag_water, 1, t.scale, 0)),  " +
                    "       sum(decode(t2.flag_sewage, 1, t.scale, 0)),  " +
                    "       sum(decode(t2.flag_solid_waste, 1, t.scale, 0)),  " +
                    "       sum(decode(t2.flag_reclaimed, 1, t.scale, 0))  " +
                    "  from ECHARTS.dm_op_yr_base_scale t, ECHARTS.dim_dept_op t1, ECHARTS.dim_op_company t2  " +
                    " where t2.dept_id = 2  " +
                    "   and t.company_id = t2.company_id  " +
                    "   and t1.dept_id = t2.dept_id  " +
                    " group by t.date_id";
            PreparedStatement preparedStatement = db.getPrepareStmt(sql);
            try {
                preparedStatement.setString(1, deptId);
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
                    map.put("invest", list2);
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
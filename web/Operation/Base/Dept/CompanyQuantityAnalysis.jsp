<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %><%--
  Created by wang at 2016/11/15 16:42
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int type = Integer.parseInt(request.getParameter("type"));
    String year = request.getParameter("year");
    String dept = request.getParameter("dept");

    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "SELECT T1.BRIEF_NAME, T.SCALE  " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T,  " +
                    "     ECHARTS.DIM_OP_COMPANY      T1,  " +
                    "     ECHARTS.DIM_DEPT_OP         T2,  " +
                    "     ECHARTS.DIM_OP_COMPANY_TYPE T3  " +
                    " WHERE T.COMPANY_ID = T1.COMPANY_ID  " +
                    "   AND T1.DEPT_ID = T2.DEPT_ID  " +
                    "   AND T1.COMPANY_TYPE = T3.TYPE_ID  " +
                    "   AND T2.DEPT_ID = " + dept +
                    "   AND T.DATE_ID =  " + year +
                    "   AND T3.TYPE_ID =" + type +"order by t.scale desc";
            try {
                ResultSet resultSet = db.executeQuery(sql);
                if (resultSet != null) {
                    Map<String, List<String>> map = new HashMap<String, List<String>>();
                    List<String> list1 = new ArrayList<String>();
                    List<String> list2 = new ArrayList<String>();
                    while (resultSet.next()) {
                        list1.add(resultSet.getString(1));
                        list2.add(resultSet.getString(2));
                    }
                    map.put("deptName", list1);
                    map.put("scale", list2);
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
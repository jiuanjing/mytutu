<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--
  Created by wang at 2016/10/16 11:19
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int type = Integer.parseInt(request.getParameter("type"));
    String year = request.getParameter("year");
    String dept = request.getParameter("dept");

    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String data = "SUM(T.SCALE)";
            if (type == 4) data = "10000*SUM(T.SCALE)";//固废的单位为吨
            String sql = "SELECT T1.COMPANY_NAME, SUM(T.FACTORY_COUNT)," + data +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T,  " +
                    "     ECHARTS.DIM_OP_COMPANY      T1,  " +
                    "     ECHARTS.DIM_DEPT_OP         T2  " +
                    " WHERE T.COMPANY_ID = T1.COMPANY_ID  " +
                    "   AND T1.DEPT_ID = T2.DEPT_ID  " +
                    "   AND T1.COMPANY_TYPE =" + type +
                    "   AND T.DATE_ID = " + year +
                    "   AND T2.DEPT_ID =" + dept +
                    " GROUP BY T1.COMPANY_NAME";
            try {
                ResultSet resultSet = db.executeQuery(sql);

                if (resultSet != null) {
                    List<List<Object>> lists = new ArrayList<List<Object>>();
                    while (resultSet.next()) {
                        List<Object> list1 = new ArrayList<Object>();
                        list1.add(resultSet.getInt(2));
                        list1.add(resultSet.getInt(3));
                        list1.add(resultSet.getInt(3) / resultSet.getInt(2));
                        list1.add(resultSet.getString(1));
                        lists.add(list1);
                    }
                    Gson gson = new Gson();
                    String returnData = gson.toJson(lists);
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
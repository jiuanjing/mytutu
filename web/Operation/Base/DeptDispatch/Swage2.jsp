<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%--
  Created by wang at 2016/11/15 17:42
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String year = request.getParameter("year");
    String dept = request.getParameter("dept");

    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "SELECT T3.TYPE_NAME TYPE_NAME, SUM(T.QUANTITY) QUANTITY, SUM(T.SCALE) SCALE" +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE     T," +
                    "   ECHARTS.DIM_OP_COMPANY          T1," +
                    "   ECHARTS.DIM_DEPT_OP             T2," +
                    "   ECHARTS.DIM_OP_SEWAGE_PROCESS_TYPE T3" +
                    " WHERE T.COMPANY_ID = T1.COMPANY_ID" +
                    "   AND T1.DEPT_ID = T2.DEPT_ID" +
                    "   AND T.PROCESS_TYPE = T3.TYPE_ID" +
                    "   AND T1.COMPANY_TYPE = 2" +
                    "   AND T.DATE_ID =" + year +
                    "   AND T2.DEPT_ID =" + dept +
                    " GROUP BY T3.TYPE_ID, T3.TYPE_NAME";
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
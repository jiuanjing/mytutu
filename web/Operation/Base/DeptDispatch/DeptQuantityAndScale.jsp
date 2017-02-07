<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%--
  Created by wang at 2016/10/13 18:42
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int type = Integer.parseInt(request.getParameter("type"));
    String year = request.getParameter("year");

    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "SELECT V2.DEPT_NAME, NVL(V1.QUANTITY, 0), NVL(V1.SCALE, 0) " +
                    "  FROM (SELECT T2.DEPT_NAME, SUM(T1.QUANTITY) QUANTITY, SUM(T1.SCALE) SCALE ,t2.dept_id" +
                    "    FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T1, ECHARTS.DIM_DEPT_OP T2 " +
                    "   WHERE T1.DEPT_ID = T2.DEPT_ID " +
                    "     AND T1.BU_ID = " + type +
                    "     AND T1.DATE_ID = " + year +
                    "   GROUP BY T2.DEPT_NAME,t2.dept_id ORDER BY t2.dept_id) V1, " +
                    "    (SELECT T3.DEPT_NAME FROM ECHARTS.DIM_DEPT_OP T3) V2 " +
                    " WHERE V1.DEPT_NAME = V2.DEPT_NAME";
            try {
                ResultSet resultSet = db.executeQuery(sql);
                if (resultSet != null) {
                    List<List<Object>> lists = new ArrayList<List<Object>>();
                    DecimalFormat decimalFormat = new DecimalFormat("#0.00");
                    while (resultSet.next()) {
                        List<Object> list1 = new ArrayList<Object>();
                        list1.add(resultSet.getDouble(2));
                        list1.add(resultSet.getDouble(3));
                        list1.add(decimalFormat.format(
                                resultSet.getDouble(3) / resultSet.getDouble(2)));
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
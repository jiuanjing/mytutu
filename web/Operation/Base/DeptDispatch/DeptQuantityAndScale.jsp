<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.DecimalFormat" %>
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
            String sql = "SELECT T2.DEPT_NAME, SUM(T1.QUANTITY), SUM(T1.SCALE) " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T1, ECHARTS.DIM_DEPT_OP T2 " +
                    " WHERE T1.DEPT_ID = T2.DEPT_ID " +
                    "   AND T1.BU_ID = " +type+
                    "   AND T1.DATE_ID = " +year+
                    " GROUP BY T2.DEPT_NAME";
            try {
                ResultSet resultSet = db.executeQuery(sql);

                if (resultSet != null) {
                    List<List<Object>> lists = new ArrayList<List<Object>>();
                    DecimalFormat decimalFormat = new DecimalFormat("#0.00");
                    while (resultSet.next()) {
                        List<Object> list1 = new ArrayList<Object>();
                        list1.add(resultSet. getDouble(2));
                        list1.add(resultSet. getDouble(3));
                        list1.add(decimalFormat.format(
                                resultSet. getDouble(3) / resultSet. getDouble(2)));
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
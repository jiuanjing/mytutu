<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%--
  Created by wang at 2016/11/16 09:37
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String year = request.getParameter("year");

    DBOperation db = new DBOperation(true);
    List<List<List<Object>>> dataList = new ArrayList<List<List<Object>>>();

    if (db.dbOpen()) {
        try {
            for (int i = 1; i < 7; i++) {
                List<List<Object>> lists = new ArrayList<List<Object>>();
                String sql = "SELECT T3.STANDARD_NAME, SUM(T.QUANTITY), SUM(T.SCALE), T2.DEPT_NAME  " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE          T,  " +
                        "     ECHARTS.DIM_OP_COMPANY               T1,  " +
                        "     ECHARTS.DIM_DEPT_OP                  T2,  " +
                        "     ECHARTS.DIM_OP_SEWAGE_STANDARD T3  " +
                        " WHERE T.COMPANY_ID = T1.COMPANY_ID  " +
                        "   AND T1.DEPT_ID = T2.DEPT_ID  " +
                        "   AND T.EFFLUENT_STANDARD = T3.STANDARD_ID  " +
                        "   AND T1.COMPANY_TYPE = 2  " +
                        "   AND T.DATE_ID =" + year +
                        "   AND T2.DEPT_ID =" + i +
                        " GROUP BY T3.STANDARD_ID, T3.STANDARD_NAME, T2.DEPT_NAME";
                try {
                    ResultSet resultSet = db.executeQuery(sql);
                    if (resultSet != null) {
                        while (resultSet.next()) {
                            List<Object> list1 = new ArrayList<Object>();
                            list1.add(resultSet.getInt(2));
                            list1.add(resultSet.getInt(3));
                            //list1.add(resultSet.getInt(3) / resultSet.getInt(2));
                            list1.add(resultSet.getString(1));
                            list1.add(resultSet.getString(4));
                            lists.add(list1);
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                dataList.add(lists);
            }
            Gson gson = new Gson();
            String s = gson.toJson(dataList);
            out.print(s);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>
<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--
  Created by wang at 2016/10/15 15:09
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String year = request.getParameter("year");

    DBOperation db = new DBOperation(true);

    if (db.dbOpen()) {
        Map<String, Object> map = new HashMap<String, Object>();
        Map<String, Object> map1 = new HashMap<String, Object>();
        Map<String, Object> map2 = new HashMap<String, Object>();
        try {
            String sql = "SELECT NVL(SUM(T.SCALE_WATER), 0), " +
                    "    NVL(SUM(T.SCALE_SEWAGE), 0), " +
                    "    NVL(SUM(T.SCALE_SOLID_WASTE / 10000), 0), " +
                    "    T1.DEPT_ID, " +
                    "    T1.DEPT_NAME," +
                    "    NVL(SUM(T.SCALE_RECLAIMED), 0) " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T, " +
                    "    ECHARTS.DIM_DEPT_OP         T1, " +
                    "    ECHARTS.DIM_OP_COMPANY      T2 " +
                    " WHERE T.DATE_ID = ? " +
                    "   AND T.COMPANY_ID = T2.COMPANY_ID " +
                    "   AND T2.DEPT_ID = T1.DEPT_ID " +
                    " GROUP BY T1.DEPT_ID, T1.DEPT_NAME " +
                    " ORDER BY T1.DEPT_ID";
            PreparedStatement preparedStatement = db.getPrepareStmt(sql);
            preparedStatement.setString(1, year);
            ResultSet resultSet = preparedStatement.executeQuery();
            if (resultSet != null) {


                List<String> list1 = new ArrayList<String>();
                List<String> list2 = new ArrayList<String>();
                List<String> list3 = new ArrayList<String>();
                List<String> list4 = new ArrayList<String>();
                List<String> list5 = new ArrayList<String>();
                while (resultSet.next()) {
                    list1.add(resultSet.getString(5));
                    list2.add(resultSet.getString(1));
                    list3.add(resultSet.getString(2));
                    list4.add(resultSet.getString(3));
                    list5.add(resultSet.getString(6));
                }
                map1.put("water", list2);
                map1.put("waste", list3);
                map1.put("solid", list4);
                map1.put("renew", list5);
                map.put("deptName", list1);
                map.put("scale", map1);
            }
            String sql2 = "SELECT NVL(SUM(T.SCALE_WATER), 0), " +
                    "    NVL(SUM(T.SCALE_SEWAGE), 0), " +
                    "    NVL(SUM(T.SCALE_SOLID_WASTE / 10000), 0), " +
                    "    T1.DEPT_ID, " +
                    "    T1.DEPT_NAME, " +
                    "    NVL(SUM(T.SCALE_RECLAIMED), 0) " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T, " +
                    "    ECHARTS.DIM_DEPT_OP         T1, " +
                    "    ECHARTS.DIM_OP_COMPANY      T2 " +
                    " WHERE T.DATE_ID = ? " +
                    "   AND T.COMPANY_ID = T2.COMPANY_ID " +
                    "   AND (T.OPERATION_STATUS LIKE '%已运营%' OR " +
                    "    T.OPERATION_STATUS LIKE '%委托运营%') " +
                    "   AND T2.DEPT_ID = T1.DEPT_ID " +
                    " GROUP BY T1.DEPT_ID, T1.DEPT_NAME " +
                    " ORDER BY T1.DEPT_ID";
            PreparedStatement preparedStatement2 = db.getPrepareStmt(sql2);
            preparedStatement2.setString(1, year);
            ResultSet resultSet2 = preparedStatement2.executeQuery();
            if (resultSet2 != null) {

                List<String> list2 = new ArrayList<String>();
                List<String> list3 = new ArrayList<String>();
                List<String> list4 = new ArrayList<String>();
                List<String> list5 = new ArrayList<String>();
                while (resultSet2.next()) {
                    list2.add(resultSet2.getString(1));
                    list3.add(resultSet2.getString(2));
                    list4.add(resultSet2.getString(3));
                    list5.add(resultSet2.getString(6));
                }
                map2.put("water", list2);
                map2.put("waste", list3);
                map2.put("solid", list4);
                map2.put("renew", list5);
                map.put("actualScale", map2);
            }
            Gson gson = new Gson();
            String returnData = gson.toJson(map);
            out.write(returnData);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>

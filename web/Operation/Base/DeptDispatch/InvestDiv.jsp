<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.bws.util.CollectionUtil" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%--
  Created by wang at 2016/11/15 15:47
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            Map<String, Object> dataMap = new HashMap<String, Object>();
            List<Object> list1 = new ArrayList<Object>();
            List<Object> list2 = new ArrayList<Object>();
            List<Object> list3 = new ArrayList<Object>();
            List<Object> list4 = new ArrayList<Object>();

            String dept = request.getParameter("dept");
            String sql = "SELECT V1.DATE_ID, V1.TYPE_NAME, NVL(SCALE, 0), V1.BU_ID " +
                    "  FROM (SELECT DATE_ID, BU_ID, T2.TYPE_NAME " +
                    "    FROM (SELECT DISTINCT (T.DATE_ID) " +
                    "      FROM ECHARTS.DM_OP_YR_BASE_SCALE_dept T where t.dept_id = " + dept + ") V11, " +
                    "      (SELECT DISTINCT (T.BU_ID) " +
                    "      FROM ECHARTS.DM_OP_YR_BASE_SCALE_dept T where t.dept_id = " + dept + ") V12, " +
                    "      ECHARTS.DIM_OP_COMPANY_TYPE T2 " +
                    "   WHERE V12.BU_ID = T2.TYPE_ID) V1, " +
                    "    (SELECT T.DATE_ID, SUM(T.INVEST_AMOUNT) SCALE, T.BU_ID " +
                    "    FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T " +
                    "   WHERE T.DEPT_ID = " + dept +
                    "   GROUP BY T.DATE_ID, T.BU_ID) V2 " +
                    " WHERE V1.DATE_ID = V2.DATE_ID(+) " +
                    "   AND V1.BU_ID = V2.BU_ID(+) " +
                    " ORDER BY BU_ID, V1.DATE_ID";
            //大区的总投资增长率
            String sql1 = "SELECT NVL(V1.GROWTH_RATE_INVEST, 0), V.DATE_ID " +
                    "  FROM (SELECT T.GROWTH_RATE_INVEST, T.DATE_ID " +
                    "    FROM ECHARTS.DM_OP_YR_BASE_GROWTH_RATE_DEPT T " +
                    "   WHERE T.DEPT_ID = " + dept + ") V1, " +
                    "    (SELECT DISTINCT (T1.DATE_ID) " +
                    "    FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T1) V " +
                    " WHERE V1.DATE_ID(+) = V.DATE_ID " +
                    " ORDER BY V.DATE_ID";

            ResultSet rs = db.executeQuery(sql);
            ResultSet rs1 = db.executeQuery(sql1);
            try {
                while (rs.next()) {
                    list1.add(rs.getString(1));
                    list2.add(rs.getString(2));
                    list3.add(rs.getString(3));
                }
                while (rs1.next()) {
                    list4.add(rs1.getString(1));
                }
                dataMap.put("year", CollectionUtil.removeDuplicateList(list1));
                dataMap.put("name", CollectionUtil.removeDuplicateList(list2));
                dataMap.put("data", list3);
                dataMap.put("rate", list4);

                Gson gson = new Gson();
                String s = gson.toJson(dataMap);
                out.print(s);
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

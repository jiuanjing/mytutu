<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.bws.util.CollectionUtil" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    //柱状图的数据格式
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            Map<String, Object> dataMap = new HashMap<String, Object>();
            List<Object> list1 = new ArrayList<Object>();
            List<Object> list2 = new ArrayList<Object>();
            List<Object> list3 = new ArrayList<Object>();
            List<Object> list4 = new ArrayList<Object>();

            String sql1 = "";
            String dept = request.getParameter("dept");
            sql1 = " SELECT NVL(V1.GROWTH_RATE, 0), V.DATE_ID " +
                    "  FROM (SELECT T.GROWTH_RATE, T.DATE_ID " +
                    "    FROM ECHARTS.DM_OP_YR_BASE_GROWTH_RATE_DEPT T " +
                    "   WHERE T.DEPT_ID = " + dept + ") V1, " +
                    "    (SELECT DISTINCT (T1.DATE_ID) " +
                    "    FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T1) V " +
                    " WHERE V1.DATE_ID(+) = V.DATE_ID " +
                    " ORDER BY V.DATE_ID ";
            ResultSet rs1 = db.executeQuery(sql1);
            try {
                while (rs1.next()) {
                    list4.add(rs1.getString(1));
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            String sql = "SELECT V1.DATE_ID,NVL(SCALE, 0),V1.BU_ID,V1.TYPE_NAME " +
            "  FROM (SELECT DATE_ID, BU_ID, T2.TYPE_NAME " +
                    "    FROM (SELECT DISTINCT (T.DATE_ID) " +
                    "      FROM ECHARTS.DM_OP_YR_BASE_SCALE_dept T ) V11, " +
                    "      (SELECT DISTINCT (T.BU_ID) " +
                    "      FROM ECHARTS.DM_OP_YR_BASE_SCALE_dept T ) V12, " +
                    "      ECHARTS.DIM_OP_COMPANY_TYPE T2 " +
                    "   WHERE V12.BU_ID = T2.TYPE_ID) V1, " +
                    "    (SELECT T.DATE_ID, SUM(T.SCALE) SCALE, T.BU_ID " +
                    "    FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T " +
                    "   WHERE T.DEPT_ID = " + dept +
                    "   GROUP BY T.DATE_ID, T.BU_ID) V2 " +
                    " WHERE V1.DATE_ID = V2.DATE_ID(+) " +
                    "   AND V1.BU_ID = V2.BU_ID(+) " +
                    " ORDER BY BU_ID, V1.DATE_ID";
            ResultSet rs = db.executeQuery(sql);

            if (rs != null) {
                try {
                    while (rs.next()) {
                        list1.add(rs.getString(1));
                        list2.add(rs.getString(2));
                        list3.add(rs.getString(4));
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                dataMap.put("year", CollectionUtil.removeDuplicateList(list1));
                dataMap.put("data", list2);
                dataMap.put("name", CollectionUtil.removeDuplicateList(list3));
                dataMap.put("rate", list4);

                Gson gson = new Gson();
                String s = gson.toJson(dataMap);
                out.print(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>


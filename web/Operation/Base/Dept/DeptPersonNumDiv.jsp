<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String year = request.getParameter("year");
            String dept = request.getParameter("dept");

            String sql = "SELECT V2.TYPE_NAME, NVL(DATA, 0) " +
                    "  FROM (SELECT SUM(T.HEADS_COUNT) DATA, T1.TYPE_NAME " +
                    "    FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T, " +
                    "      ECHARTS.DIM_OP_COMPANY_TYPE      T1 " +
                    "   WHERE T.DATE_ID = " +year+
                    "     AND T1.TYPE_ID = T.BU_ID " +
                    "     AND T.DEPT_ID = " +dept+
                    "   GROUP BY T1.TYPE_NAME) V1, " +
                    "    (SELECT T1.TYPE_NAME, T1.TYPE_ID FROM ECHARTS.DIM_OP_COMPANY_TYPE T1) V2 " +
                    " WHERE V1.TYPE_NAME(+) = V2.TYPE_NAME " +
                    " ORDER BY V2.TYPE_ID";

            ResultSet rs = db.executeQuery(sql);
            Map<String, List<String>> dataMap = new HashMap<String, List<String>>();
            List<String> list1 = new ArrayList<String>();
            List<String> list2 = new ArrayList<String>();
            if (rs != null) {
                try {
                    while (rs.next()) {
                        list1.add(rs.getString(1));
                        list2.add(rs.getString(2));
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            dataMap.put("name", list1);
            dataMap.put("data", list2);

            Gson gson = new Gson();
            String s = gson.toJson(dataMap);
            out.write(s);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>



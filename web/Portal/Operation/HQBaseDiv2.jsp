<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String types = request.getParameter("types");
            String sql = "";
            //1->运营年限分析
            String year = request.getParameter("year");
            if ("1".equals(types)) {
                sql = "SELECT SUM(T.QUANTITY), T1.YEARS_NAME  " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE_ALL T, ECHARTS.DIM_OP_YEARS T1  " +
                        " WHERE T.DATE_ID =  " + year +
                        "   AND T.OP_YEARS = T1.YEARS_ID  " +
                        " GROUP BY T.OP_YEARS, T1.YEARS_NAME  " +
                        " ORDER BY T.OP_YEARS";
            }
            //2->公司类型分析
            if ("2".equals(types)) {
                sql = "SELECT SUM(T.QUANTITY),T1.TYPE_NAME " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE_ALL T, ECHARTS.DIM_OP_COMPANY_TYPE T1 " +
                        " WHERE T.DATE_ID = " + year +
                        "   AND T.BU_ID = T1.TYPE_ID " +
                        " GROUP BY T.BU_ID, T1.TYPE_NAME";
            }

            ResultSet rs = db.executeQuery(sql);
            if (rs != null) {
                List<Map<String, String>> dataList = new ArrayList<Map<String, String>>();
                try {
                    while (rs.next()) {
                        Map<String, String> map = new HashMap<String, String>();
                        map.put("value", rs.getString(1));
                        map.put("name", rs.getString(2));
                        dataList.add(map);
                    }
                    Gson gson = new Gson();
                    String s = gson.toJson(dataList);
                    out.write(s);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>


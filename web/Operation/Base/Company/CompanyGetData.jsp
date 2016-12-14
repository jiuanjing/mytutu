<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation dbOperation = new DBOperation(true);
    if (dbOperation.dbOpen()) {
        try {
            String deptId = request.getParameter("deptId");
            deptId = deptId.length() == 0 ? "1" : deptId;
            String sql = "SELECT T1.BRIEF_NAME, " +
                    "    T.OPERATION_STATUS, " +
                    "    T.PROJECT_PROPERTY, " +
                    "    T3.TYPE_NAME, " +
                    "    T.FACTORY_COUNT, " +
                    "    T.BUILT_TIME, " +
                    "    T4.YEARS_NAME, " +
                    "    T.YEAR_LIMIT, " +
                    "    T.STOCK_PERCENT, " +
                    "    T.REGISTER_CAPITAL, " +
                    "    T.HEADS_COUNT_TOP + T.HEADS_COUNT_MIDDLE + T.HEADS_COUNT_BASE, " +
                    "    T.HEADS_COUNT_TOP, " +
                    "    T.HEADS_COUNT_MIDDLE, " +
                    "    T.HEADS_COUNT_BASE, " +
                    "    T.SCALE_WATER, " +
                    "    T.SCALE_SEWAGE, " +
                    "    T.SCALE_RECLAIMED, " +
                    "    T.SCALE_WATER + T.SCALE_SEWAGE + T.SCALE_RECLAIMED, " +
                    "    T.SCALE_SOLID_WASTE " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T, " +
                    "    ECHARTS.DIM_OP_COMPANY      T1, " +
                    "    ECHARTS.DIM_DEPT_OP         T2, " +
                    "    ECHARTS.DIM_OP_COMPANY_TYPE T3, " +
                    "    ECHARTS.DIM_OP_YEARS        T4 " +
                    " WHERE T.COMPANY_ID = T1.COMPANY_ID " +
                    "   AND T1.DEPT_ID = T2.DEPT_ID " +
                    "   AND T1.COMPANY_TYPE = T3.TYPE_ID " +
                    "   AND T.OP_YEARS = T4.YEARS_ID " +
                    "   AND T2.DEPT_ID = " + deptId +
                    "   AND T.DATE_ID = " +
                    "    (SELECT MAX(T.DATE_ID) FROM ECHARTS.DM_OP_YR_BASE_SCALE T)";

            Map<String, Object> dataMap = new HashMap<String, Object>();
            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
            ResultSet rs = dbOperation.executeQuery(sql);

            if (rs != null) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    for (int i = 1; i < 20; i++) {
                        map.put("a" + i, rs.getString(i));
                    }
                    list.add(map);
                }
            }
            dataMap.put("total", list.size());
            dataMap.put("rows", list);
            Gson gson = new Gson();
            String s = gson.toJson(dataMap);
            out.write(s);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            dbOperation.dbClose();
        }
    }
%>

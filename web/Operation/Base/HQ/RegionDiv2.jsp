<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation dbOperation = new DBOperation(true);
    String province = request.getParameter("province");
    province = URLDecoder.decode(province, "UTF-8");

    if (dbOperation.dbOpen()) {
        try {
            String sql2 = "SELECT T.KPI_TYPE,T.KPI_NAME, T.KPI_VALUE, T.KPI_ID " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_MAP_OVERVIEW T " +
                    " WHERE T.region_name = '" + province +
                    "' and T.DATE_ID = " +
                    "    (SELECT MAX(T.DATE_ID) FROM ECHARTS.DM_OP_YR_BASE_MAP_OVERVIEW T) " +
                    " ORDER BY T.KPI_ID";
            Map<String, Object> dataMap = new HashMap<String, Object>();
            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
            ResultSet rs2 = dbOperation.executeQuery(sql2);

            if (rs2 != null) {
                while (rs2.next()) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    map.put("kpiType", rs2.getString(1));
                    map.put("kpiName", rs2.getString(2));
                    map.put("kpiValue", rs2.getString(3));
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
    } else {
        out.write("对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！");
    }
%>

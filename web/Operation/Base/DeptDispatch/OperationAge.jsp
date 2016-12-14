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
    String year = request.getParameter("year");
    String buId = request.getParameter("buId");

    if (dbOperation.dbOpen()) {
        try {
            String sql2 = "SELECT T1.BRIEF_NAME, T2.DEPT_NAME, T3.YEARS_NAME " +
                    "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T, " +
                    "    ECHARTS.DIM_OP_COMPANY      T1, " +
                    "    ECHARTS.DIM_DEPT_OP         T2, " +
                    "    ECHARTS.DIM_OP_YEARS        T3 " +
                    " WHERE T.COMPANY_ID = T1.COMPANY_ID " +
                    "   AND T1.DEPT_ID = T2.DEPT_ID " +
                    "   AND T3.YEARS_ID = T.OP_YEARS " +
                    "   AND T1.COMPANY_TYPE = " + buId +
                    "   AND T.DATE_ID = " + year +
                    "order by t3.years_id";
            Map<String, Object> dataMap = new HashMap<String, Object>();
            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
            ResultSet rs2 = dbOperation.executeQuery(sql2);

            if (rs2 != null) {
                while (rs2.next()) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    map.put("companyName", rs2.getString(1));
                    map.put("deptName", rs2.getString(2));
                    map.put("opYears", rs2.getString(3));
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
        out.write("<script>'对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！'</script>");
    }
%>

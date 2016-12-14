<%@page import="com.google.gson.Gson" %>
<%@page import="java.sql.SQLException" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.lang.reflect.Array" %>
<%@page import="java.util.List" %>
<%@page import="java.util.Map" %>
<%@page import="java.util.HashMap" %>
<%@page import="com.bws.dbOperation.DBOperation" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation db = new DBOperation(true);
    String company = new String(request.getParameter("company").getBytes("ISO-8859-1"), "utf-8");
    String kpi = new String(request.getParameter("kpi").getBytes("ISO-8859-1"), "utf-8");

    Map<String, Object> gsonmap = new HashMap<String, Object>();
    List<String> sqlList = new ArrayList<String>();

    if (db.dbOpen()) {
        try {
            //查询实际值
            String sql1 = "select t.comp_score,t.company_id,t.date_id" +
                    "  from echarts.dm_op_yr_evaluate t, echarts.dim_op_kpi t1, echarts.dim_op_company t2" +
                    " where t1.kpi_id = t.kpi_id" +
                    "   and t.company_id = t2.company_id" +
                    "   and t1.kpi_id = '" + kpi + "'" +
                    "   and t2.brief_name ='" + company + "'" +
                    "order by t.date_id";
            //行业标杆值
            String sql2 = "select t.comp_score,t.company_id,t.date_id" +
                    "  from echarts.dm_op_yr_evaluate t, echarts.dim_op_kpi t1, echarts.dim_op_company t2" +
                    " where t1.kpi_id = t.kpi_id" +
                    "   and t1.kpi_id = '" + kpi + "'" +
                    "   and t.company_id = -1 " +
                    "order by t.date_id";
            //行业平均值
            String sql3 = "select t.comp_score,t.company_id,t.date_id" +
                    "  from echarts.dm_op_yr_evaluate t, echarts.dim_op_kpi t1, echarts.dim_op_company t2" +
                    " where t1.kpi_id = t.kpi_id" +
                    "   and t1.kpi_id = '" + kpi + "'" +
                    "   and t.company_id = 0 " +
                    "order by t.date_id";

            sqlList.add(sql1);
            sqlList.add(sql2);
            sqlList.add(sql3);

            for (int i = 0; i < sqlList.size(); i++) {
                ResultSet rs = db.executeQuery(sqlList.get(i));
                if (rs != null) {
                    try {
                        List<String> list = new ArrayList<String>();
                        while (rs.next()) {
                            list.add(rs.getString(1));
                        }
                        gsonmap.put("data" + (i + 1), list);
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }

            Gson gson = new Gson();
            String s = gson.toJson(gsonmap);
            out.write(s);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    } else {
        out.write("<script>alert('对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！');</script>");
    }
%>
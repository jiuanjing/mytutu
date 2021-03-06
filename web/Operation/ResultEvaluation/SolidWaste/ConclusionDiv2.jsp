<%@page import="com.google.gson.Gson" %>
<%@page import="java.sql.SQLException" %>
<%@page import="java.sql.ResultSet" %>
<%@page import="java.util.List" %>
<%@page import="java.util.ArrayList" %>
<%@page import="java.util.Map" %>
<%@page import="java.util.HashMap" %>
<%@page import="com.bws.dbOperation.DBOperation" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation db = new DBOperation(true);
    String date = new String(request.getParameter("date").getBytes("ISO-8859-1"), "gbk");
    date = date.equals("") ? "2015" : date;
    int dateID = Integer.parseInt(date);
    String company = new String(request.getParameter("company").getBytes("ISO-8859-1"), "utf-8");

    if (db.dbOpen()) {
        Map<String, Object> gsonmap = new HashMap<String, Object>();
        List<String> sqlList = new ArrayList<String>();

        //获取标杆值
        String sql1 = "select t.comp_score from echarts.dm_op_yr_evaluate t  where t.date_id = " + dateID
                + " and t.kpi_id in (4100,4200,4300,4400,4500,4600,4700) and t.company_id = -1 order by t.kpi_id";
        //获取第一年实际值
        String sql2 = "select t.comp_score from echarts.dm_op_yr_evaluate t ,echarts.dim_op_company t2 where t.date_id = " + dateID
                + " and t.kpi_id in (4100,4200,4300,4400,4500,4600,4700) and t.company_id = t2.company_id and t2.flag_solid_waste = 1 and  t2.brief_name = '" + company + "' order by t.kpi_id";
        //获取第二年实际值
        String sql3 = "select t.comp_score from echarts.dm_op_yr_evaluate t ,echarts.dim_op_company t2 where t.date_id = " + (dateID - 1)
                + " and t.kpi_id in (4100,4200,4300,4400,4500,4600,4700) and t.company_id = t2.company_id and t2.flag_solid_waste = 1 and t2.brief_name = '" + company + "' order by t.kpi_id";
        //获取第三年实际值
        String sql4 = "select t.comp_score from echarts.dm_op_yr_evaluate t ,echarts.dim_op_company t2 where t.date_id =" + (dateID - 2)
                + " and t.kpi_id in (4100,4200,4300,4400,4500,4600,4700) and t.company_id = t2.company_id and t2.flag_solid_waste = 1 and t2.brief_name = '" + company + "' order by t.kpi_id";

        sqlList.add(sql1);
        sqlList.add(sql2);
        sqlList.add(sql3);
        sqlList.add(sql4);

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

        db.dbClose();

        Gson gson = new Gson();
        String s = gson.toJson(gsonmap);
        out.write(s);
    } else {
        out.write("<script>alert('对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！');</script>");
    }
%>
<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String date = request.getParameter("date");
    date = date.equals("") ? "2015" : date;
    int dateID = Integer.parseInt(date);
    String company = new String(request.getParameter("company").getBytes("ISO-8859-1"), "utf-8");


    DBOperation dbOperation = new DBOperation(true);
    if (dbOperation.dbOpen()) {
        try {
            Map<String, Object> gsonmap = new HashMap<String, Object>();

            List<String> sqlList = new ArrayList<String>();

            //获取标杆值
            String sql1 = "select t.actual_value from echarts.dm_op_yr_evaluate t  where t.date_id = " + dateID
                    + " and t.kpi_id in (1501,1502,1503,1504) and t.company_id = -1 order by t.kpi_id";
            //获取第一年实际值
            String sql2 = "select t.actual_value from echarts.dm_op_yr_evaluate t ,echarts.dim_op_company t2 where t.date_id = " + dateID
                    + " and t.kpi_id in (1501,1502,1503,1504) and t.company_id = t2.company_id and t2.brief_name = '" + company + "' order by t.kpi_id";
            //获取第二年实际值
            String sql3 = "select t.actual_value from echarts.dm_op_yr_evaluate t ,echarts.dim_op_company t2 where t.date_id = " + (dateID - 1)
                    + " and t.kpi_id in (1501,1502,1503,1504) and t.company_id = t2.company_id and t2.brief_name = '" + company + "' order by t.kpi_id";
            //获取第三年实际值
            String sql4 = "select t.actual_value from echarts.dm_op_yr_evaluate t ,echarts.dim_op_company t2 where t.date_id =" + (dateID - 2)
                    + " and t.kpi_id in (1501,1502,1503,1504) and t.company_id = t2.company_id and t2.brief_name = '" + company + "' order by t.kpi_id";

            sqlList.add(sql1);
            sqlList.add(sql2);
            sqlList.add(sql3);
            sqlList.add(sql4);

            for (int i = 0; i < sqlList.size(); i++) {
                ResultSet rs = dbOperation.executeQuery(sqlList.get(i));
                if (null != rs) {
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
            dbOperation.dbClose();
        }
    } else {
        out.write("<script>alert('对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！');</script>");
    }
%>

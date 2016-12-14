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
            String sql = "select a.city_name city_name,  " +
                    "sum(d.quantity) company_count,  " +
                    "sum(d.scale) scale,  " +
                    "sum(d.factory_count) factory_count,  " +
                    "sum(d.invest_amount) invest_amount,  " +
                    "sum(d.heads_count) heads_count    " +
                    "from ECHARTS.dim_city a,ECHARTS.dim_region b,ECHARTS.dim_op_company c," +
                    "ECHARTS.dm_op_yr_base_scale d   " +
                    "where a.city_id=c.city_id and c.company_id=d.company_id  " +
                    "and c.region_id=b.region_id and b.brief_name= '" + province + "'" +
                    " and d.date_id=(select max(date_id) from echarts.dm_op_yr_base_scale)   " +
                    "group by a.city_name";
//            System.out.println(sql);
            ResultSet resultSet = dbOperation.executeQuery(sql);
            Map<String, List<Map<String, Object>>> dataMap = new HashMap<String, List<Map<String, Object>>>();
            List<Map<String, Object>> list1 = new ArrayList<Map<String, Object>>();
            List<Map<String, Object>> list2 = new ArrayList<Map<String, Object>>();
            List<Map<String, Object>> list3 = new ArrayList<Map<String, Object>>();
            if (resultSet != null) {
                while (resultSet.next()) {
                    Map<String, Object> map1 = new HashMap<String, Object>();
                    Map<String, Object> map2 = new HashMap<String, Object>();
                    Map<String, Object> map3 = new HashMap<String, Object>();

                    map1.put("name", resultSet.getString(1));
                    map1.put("value", Double.parseDouble(resultSet.getString(3)));
                    map2.put("name", resultSet.getString(1));
                    map2.put("value", Double.parseDouble(resultSet.getString(2)));
                    map3.put("name", resultSet.getString(1));
                    map3.put("value", Double.parseDouble(resultSet.getString(5)));

                    list1.add(map1);
                    list2.add(map2);
                    list3.add(map3);
                }
                dataMap.put("scale", list1);
                dataMap.put("count", list2);
                dataMap.put("invest", list3);
            }
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

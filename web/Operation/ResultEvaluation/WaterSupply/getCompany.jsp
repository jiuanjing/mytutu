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
    DBOperation db = new DBOperation(true);
    String company = request.getParameter("company");

    String type = request.getParameter("type");
    int type1 = Integer.parseInt(type);

    if (db.dbOpen()) {
        String sql = "";
        if (type1 == 1) {
            sql = "select distinct t.brief_name,t.company_id from echarts.dim_op_company t,echarts.dm_op_yr_evaluate t1 where t.company_id = t1.company_id and t.flag_water = 1  ";
        } else if (type1 == 2) {
            sql = "select distinct t.brief_name,t.company_id from echarts.dim_op_company t,echarts.dm_op_yr_evaluate t1 where t.company_id = t1.company_id and t.flag_sewage = 1";
        } else if (type1 == 4) {
            sql = "select distinct t.brief_name,t.company_id from echarts.dim_op_company t,echarts.dm_op_yr_evaluate t1 where t.company_id = t1.company_id and t.flag_solid_waste = 1 ";
        }
        ResultSet rs = db.executeQuery(sql);
        List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
        if (null != rs) {
            try {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    if (company.equals(rs.getString(1))) {
                        map.put("id", rs.getString(2));
                        map.put("text", rs.getString(1));
                        map.put("selected", true);

                    } else {
                        map.put("id", rs.getString(2));
                        map.put("text", rs.getString(1));
                    }

                    list.add(map);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                db.dbClose();
            }
        }
        Gson gson = new Gson();
        String str = gson.toJson(list);
        out.write(str);
    }
%>

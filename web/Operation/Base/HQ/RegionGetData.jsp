<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation dbOperation = new DBOperation(true);
    if (dbOperation.dbOpen()) {
        try {
            String sql = "SELECT A.BRIEF_NAME PROVINCE_NAME, " +
                    "    SUM(C.QUANTITY) COMPANY_COUNT, " +
                    "    SUM(C.SCALE) SCALE, " +
                    "    SUM(C.FACTORY_COUNT) FACTORY_COUNT, " +
                    "    round(SUM(C.INVEST_AMOUNT/10000),2) INVEST_AMOUNT, " +
                    "    SUM(C.HEADS_COUNT) HEADS_COUNT " +
                    "  FROM ECHARTS.DIM_REGION A, ECHARTS.DIM_OP_COMPANY B, ECHARTS.DM_OP_YR_BASE_SCALE C " +
                    " WHERE A.REGION_ID = B.REGION_ID " +
                    "   AND B.COMPANY_ID = C.COMPANY_ID " +
                    "   AND C.DATE_ID = (SELECT MAX(DATE_ID) FROM ECHARTS.DM_OP_YR_BASE_SCALE) " +
                    " GROUP BY A.BRIEF_NAME";
            ResultSet resultSet = dbOperation.executeQuery(sql);
            Map<String,List<Map<String,Object>>> dataMap = new HashMap<String,List<Map<String,Object>>>();
            List<Map<String,Object>> list1 = new ArrayList<Map<String, Object>>();
            List<Map<String,Object>> list2 = new ArrayList<Map<String, Object>>();
            List<Map<String,Object>> list3 = new ArrayList<Map<String, Object>>();
            if (resultSet!=null){
                while (resultSet.next()){
                    Map<String,Object> map1 = new HashMap<String, Object>();
                    Map<String,Object> map2 = new HashMap<String, Object>();
                    Map<String,Object> map3 = new HashMap<String, Object>();

                    map1.put("name",resultSet.getString(1));
                    map1.put("value",Double.parseDouble(resultSet.getString(3)));
                    map2.put("name",resultSet.getString(1));
                    map2.put("value",Double.parseDouble(resultSet.getString(2)));
                    map3.put("name",resultSet.getString(1));
                    map3.put("value",Double.parseDouble(resultSet.getString(5)));

                    list1.add(map1);
                    list2.add(map2);
                    list3.add(map3);
                }
                dataMap.put("scale",list1);
                dataMap.put("count",list2);
                dataMap.put("invest",list3);
            }
            Gson gson = new Gson();
            String s= gson.toJson(dataMap);
            out.write(s);
        } catch (Exception e) {
            e.printStackTrace();
        }finally {
            dbOperation.dbClose();
        }
    } else {
        out.write("对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！");
    }
%>

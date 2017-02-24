<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="com.bws.util.CollectionUtil" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    //柱状图的数据格式
    DBOperation db = new DBOperation(true);
    Map<String, Object> dataMap = new HashMap<String, Object>();
    List<Object> list1 = new ArrayList<Object>();
    List<Object> list2 = new ArrayList<Object>();
    List<Object> list3 = new ArrayList<Object>();
    if (db.dbOpen()) {
        try {
            List<Object> list4 = new ArrayList<Object>();

            String types = request.getParameter("types");
            String data = "";
            String sql1 = "";
            if ("1".equals(types)) {
                data = "SUM(T.SCALE)";
                //整个公司的增长率
                sql1 = "SELECT T.GROWTH_RATE " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_GROWTH_RATE_ALL T " +
                        " ORDER BY T.DATE_ID";
                ResultSet rs1 = db.executeQuery(sql1);
                while (rs1.next()) {
                    list4.add(rs1.getString(1));
                }
            }
            if ("2".equals(types)) data = "SUM(T.Quantity)";
            if ("3".equals(types)) data = "round(SUM(T.SCALE)/SUM(T.Quantity),2)";
            if ("4".equals(types)) data = "round(SUM(T.invest_amount)/10000,2)";

            Calendar calendar = Calendar.getInstance();
            int year =  calendar.get(Calendar.YEAR) - 8;

            String sql = "SELECT V1.DATE_ID, NVL(SCALE, 0), V1.BU_ID, V1.TYPE_NAME  " +
                    "  FROM (SELECT DATE_ID, BU_ID, T2.TYPE_NAME  " +
                    "      FROM (SELECT DISTINCT (T.DATE_ID)  " +
                    "          FROM ECHARTS.DM_OP_YR_BASE_SCALE_ALL T) V11,  " +
                    "         (SELECT DISTINCT (T.BU_ID)  " +
                    "          FROM ECHARTS.DM_OP_YR_BASE_SCALE_ALL T) V12,  " +
                    "         ECHARTS.DIM_OP_COMPANY_TYPE T2  " +
                    "     WHERE V12.BU_ID = T2.TYPE_ID) V1,  " +
                    "     (SELECT T.DATE_ID, " + data + " SCALE, T.BU_ID  " +
                    "      FROM ECHARTS.DM_OP_YR_BASE_SCALE_ALL T  " +
                    "     GROUP BY T.DATE_ID, T.BU_ID) V2  " +
                    " WHERE V1.DATE_ID = V2.DATE_ID(+) and v1.date_id > " +year +
                    "   AND V1.BU_ID = V2.BU_ID(+)  " +
                    " ORDER BY BU_ID, V1.DATE_ID";
            ResultSet rs = db.executeQuery(sql);


            if (rs != null) {
                try {
                    while (rs.next()) {
                        list1.add(rs.getString(1));
                        list2.add(rs.getString(2));
                        list3.add(rs.getString(4));
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                dataMap.put("year", CollectionUtil.removeDuplicateList(list1));
                dataMap.put("data", list2);
                dataMap.put("name", CollectionUtil.removeDuplicateList(list3));
                dataMap.put("rate", list4);

                Gson gson = new Gson();
                String s = gson.toJson(dataMap);

                out.print(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>


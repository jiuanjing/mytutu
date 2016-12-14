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
    DBOperation db = new DBOperation();
    if (db.dbOpen()) {
        try {
            String year = request.getParameter("year");
            //1-污水处理工艺 2-污水排放标准
            String type = request.getParameter("type");

            Map<String, List<String>> dataMap = new HashMap<String, List<String>>();
            List<String> dataList = new ArrayList<String>();

            for (int i = 1; i < 7; i++) {
                String sql = "";
                if ("1".equals(type)) {
                    sql = "SELECT V1.DEPT_NAME, T1.TYPE_NAME, T1.TYPE_ID, COUNT(V1.COMPANY_ID) " +
                            "  FROM ECHARTS.DIM_OP_SEWAGE_PROCESS_TYPE T1, " +
                            "    (SELECT T2.DATE_ID, " +
                            "      T4.DEPT_NAME, " +
                            "      T3.COMPANY_ID, " +
                            "      T4.DEPT_ID, " +
                            "      T2.PROCESS_TYPE " +
                            "    FROM ECHARTS.DM_OP_YR_BASE_SCALE T2, " +
                            "      ECHARTS.DIM_OP_COMPANY      T3, " +
                            "      ECHARTS.DIM_DEPT_OP         T4 " +
                            "   WHERE T2.COMPANY_ID = T3.COMPANY_ID " +
                            "     AND T3.DEPT_ID = T4.DEPT_ID " +
                            "     AND T2.DATE_ID = " + year +
                            "     AND T3.DEPT_ID =  " + i +
                            "     AND T3.COMPANY_TYPE = 2 " +
                            "     AND T2.OP_YEARS <> 0) V1 " +
                            " WHERE T1.TYPE_ID = V1.PROCESS_TYPE(+) " +
                            " GROUP BY V1.DEPT_NAME, T1.TYPE_NAME, T1.TYPE_ID " +
                            " ORDER BY T1.TYPE_ID";
                }
                if ("2".equals(type)) {
                    sql = "SELECT V1.DEPT_NAME, T1.STANDARD_NAME, T1.STANDARD_ID, COUNT(V1.COMPANY_ID)" +
                            "  FROM ECHARTS.DIM_OP_SEWAGE_STANDARD T1," +
                            "   (SELECT T2.DATE_ID," +
                            "   T4.DEPT_NAME," +
                            "   T3.COMPANY_ID," +
                            "   T4.DEPT_ID," +
                            "   T2.EFFLUENT_STANDARD" +
                            "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T2," +
                            "   ECHARTS.DIM_OP_COMPANY      T3," +
                            "   ECHARTS.DIM_DEPT_OP         T4" +
                            " WHERE T2.COMPANY_ID = T3.COMPANY_ID" +
                            "   AND T3.DEPT_ID = T4.DEPT_ID" +
                            "   AND T2.DATE_ID =" + year +
                            "   AND T3.DEPT_ID = " + i +
                            "   AND T3.COMPANY_TYPE = 2" +
                            "   AND T2.OP_YEARS <> 0) V1" +
                            " WHERE T1.STANDARD_ID = V1.EFFLUENT_STANDARD(+)" +
                            " GROUP BY V1.DEPT_NAME, T1.STANDARD_NAME, T1.STANDARD_ID" +
                            " ORDER BY T1.STANDARD_ID";
                }
                ResultSet resultSet = db.executeQuery(sql);
                if (resultSet != null) {
                    List<String> typeList = new ArrayList<String>();
                    try {
                        while (resultSet.next()) {
                            typeList.add(resultSet.getString(2));
                            dataList.add(resultSet.getString(4));
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    dataMap.put("type", typeList);
                }
            }
            dataMap.put("data", dataList);
            String nameSql = "SELECT T.DEPT_NAME, T.DEPT_ID FROM " +
                    "ECHARTS.DIM_DEPT_OP T ORDER BY T.DEPT_ID";
            ResultSet nameRs = db.executeQuery(nameSql);
            try {
                List<String> nameList = new ArrayList<String>();
                while (nameRs.next()) {
                    nameList.add(nameRs.getString(1));
                }
                dataMap.put("name", nameList);
            } catch (SQLException e) {
                e.printStackTrace();
            }
            db.dbClose();
            Gson gson = new Gson();
            String s = gson.toJson(dataMap);
            out.write(s);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>


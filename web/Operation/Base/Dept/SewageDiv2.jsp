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
            String dept = request.getParameter("dept");
            //1-污水处理工艺 2-污水排放标准
            String type = request.getParameter("type");

            String sql = "";
            if ("1".equals(type)) {
                sql = "SELECT V1.TYPE_NAME, NVL(V2.INFO, 0)  " +
                        "  FROM ECHARTS.DIM_OP_SEWAGE_PROCESS_TYPE V1,  " +
                        "     (SELECT T3.TYPE_NAME, SUM(T.SCALE) INFO, T3.TYPE_ID  " +
                        "      FROM ECHARTS.DM_OP_YR_BASE_SCALE     T,  " +
                        "         ECHARTS.DIM_OP_COMPANY          T1,  " +
                        "         ECHARTS.DIM_DEPT_OP             T2,  " +
                        "         ECHARTS.DIM_OP_SEWAGE_PROCESS_TYPE T3  " +
                        "     WHERE T.COMPANY_ID = T1.COMPANY_ID  " +
                        "       AND T1.DEPT_ID = T2.DEPT_ID  " +
                        "       AND T.PROCESS_TYPE = T3.TYPE_ID  " +
                        "       AND T.DATE_ID =" + year +
                        "       AND T2.DEPT_ID =  " + dept +
                        "     GROUP BY T3.TYPE_NAME, T3.TYPE_ID) V2  " +
                        " WHERE V1.TYPE_ID = V2.TYPE_ID(+)";
            }
            if ("2".equals(type)) {
                sql = "SELECT V1.STANDARD_NAME, NVL(V2.INFO, 0)  " +
                        "  FROM ECHARTS.DIM_OP_SEWAGE_STANDARD V1,  " +
                        "     (SELECT T3.STANDARD_NAME, SUM(T.SCALE) INFO, T3.STANDARD_ID  " +
                        "      FROM ECHARTS.DM_OP_YR_BASE_SCALE          T,  " +
                        "         ECHARTS.DIM_OP_COMPANY               T1,  " +
                        "         ECHARTS.DIM_DEPT_OP                  T2,  " +
                        "         ECHARTS.DIM_OP_SEWAGE_STANDARD T3  " +
                        "     WHERE T.COMPANY_ID = T1.COMPANY_ID  " +
                        "       AND T1.DEPT_ID = T2.DEPT_ID  " +
                        "       AND T.EFFLUENT_STANDARD = T3.STANDARD_ID  " +
                        "       AND T.DATE_ID =" + year +
                        "       AND T2.DEPT_ID =  " + dept +
                        "     GROUP BY T3.STANDARD_NAME, T3.STANDARD_ID) V2  " +
                        " WHERE V1.STANDARD_ID = V2.STANDARD_ID(+)";
            }
            ResultSet resultSet = db.executeQuery(sql);
            Map<String, List<String>> dataMap = new HashMap<String, List<String>>();

            if (resultSet != null) {
                List<String> dataList = new ArrayList<String>();
                List<String> nameList = new ArrayList<String>();
                try {
                    while (resultSet.next()) {
                        nameList.add(resultSet.getString(1));
                        dataList.add(resultSet.getString(2));
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                dataMap.put("name", nameList);
                dataMap.put("data", dataList);
            }


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


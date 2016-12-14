<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String year = request.getParameter("year");
            //限定类别 0-all 1-供 2-污 3-再 4-固
            String type = request.getParameter("types");

            Map<String, List<String>> dataMap = new HashMap<String, List<String>>();
            List<String> dataList = new ArrayList<String>();
            //7个大区的数据
            for (int i = 1; i < 8; i++) {
                String sql = "select * from ( SELECT V1.DEPT_NAME, V2.YEARS_ID, V2.YEARS_NAME, NVL(DATA, 0) " +
                        "  FROM (SELECT T2.DEPT_NAME, " +
                        "      T1.OP_YEARS, " +
                        "      T3.YEARS_NAME, " +
                        "      sum(t1.quantity) DATA, " +
                        "      T3.YEARS_ID " +
                        "    FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T1, " +
                        "      ECHARTS.DIM_DEPT_OP              T2, " +
                        "      ECHARTS.DIM_OP_YEARS             T3 " +
                        "   WHERE T1.DEPT_ID = T2.DEPT_ID " +
                        "     AND T1.OP_YEARS = T3.YEARS_ID " +
                        "     AND T1.DATE_ID =  " +year+
                        "     AND T1.DEPT_ID = " +i+
                        "AND T1.BU_ID = "+type+
                        "   GROUP BY T3.YEARS_NAME, T1.OP_YEARS, T2.DEPT_NAME, T3.YEARS_ID " +
                        "   ORDER BY T3.YEARS_ID) V1, " +
                        "    (SELECT * FROM ECHARTS.DIM_OP_YEARS) V2 " +
                        " WHERE V1.OP_YEARS(+) = V2.YEARS_ID) " +
                        " ORDER BY YEARS_ID";
                ResultSet resultSet = db.executeQuery(sql);
                if (resultSet != null) {
                    List<String> typeList = new ArrayList<String>();
                    try {
                        while (resultSet.next()) {
                            typeList.add(resultSet.getString(3));
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

<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %><%--
  Created by wang at 2016/10/13 15:09
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%


    int type = Integer.parseInt(request.getParameter("type"));
    String year = request.getParameter("year");

    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "";
            //1-供水，2-污水，3-再生水，4-固废，5-供排一体，6-海水淡化
            if (type > 0 && type < 7) {
                sql = "SELECT T2.DEPT_NAME, SUM(T1.SCALE) " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE_DEPT T1, ECHARTS.DIM_DEPT_OP T2 " +
                        " WHERE T1.DEPT_ID = T2.DEPT_ID " +
                        "   AND T1.DATE_ID = " + year +
                        "   AND T1.BU_ID = " + type +
                        " GROUP BY T2.DEPT_NAME";
            }
            //11-污水处理工艺
            if (type == 11) {
                sql = "SELECT T1.TYPE_NAME, COUNT(1) " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T, " +
                        "   ECHARTS.DIM_OP_SEWAGE_PROCESS_TYPE T1," +
                        "   ECHARTS.DIM_OP_COMPANY T2 " +
                        " WHERE T.COMPANY_ID = T2.COMPANY_ID " +
                        "   AND T.PROCESS_TYPE = T1.TYPE_ID " +
                        "   AND T.DATE_ID = " + year +
                        "   AND T2.COMPANY_TYPE = 2 " +
                        " GROUP BY T1.TYPE_NAME";
            }
            //12-污水排放标准
            if (type == 12) {
                sql = "SELECT T1.STANDARD_NAME, COUNT(1)" +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE          T," +
                        "   ECHARTS.DIM_OP_SEWAGE_STANDARD T1," +
                        "   ECHARTS.DIM_OP_COMPANY               T2" +
                        " WHERE T.COMPANY_ID = T2.COMPANY_ID" +
                        "   AND T.EFFLUENT_STANDARD = T1.STANDARD_ID" +
                        "   AND T.DATE_ID = " + year +
                        "   AND T2.COMPANY_TYPE = 2" +
                        " GROUP BY T1.STANDARD_NAME";
            }

            try {
                ResultSet resultSet = db.executeQuery(sql);

                if (resultSet != null) {
                    List<Map<String, String>> list = new ArrayList<Map<String, String>>();
                    while (resultSet.next()) {
                        Map<String, String> map = new HashMap<String, String>();
                        map.put("name", resultSet.getString(1));
                        map.put("value", resultSet.getString(2));

                        list.add(map);
                    }
                    Gson gson = new Gson();
                    String returnData = gson.toJson(list);
                    out.write(returnData);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>

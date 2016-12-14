<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %><%--
  Created by wang at 2016/11/16 10:09
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    int type = Integer.parseInt(request.getParameter("type"));
    String year = request.getParameter("year");
    String dept = request.getParameter("dept");

    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String sql = "";
            //1-供水，2-污水，3-再生水，4-固废，5-供排一体
            if (type > 0 && type < 6) {
                sql = "SELECT T1.BRIEF_NAME, T.FACTORY_COUNT  " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE T,  " +
                        "     ECHARTS.DIM_OP_COMPANY      T1,  " +
                        "     ECHARTS.DIM_DEPT_OP         T2,  " +
                        "     ECHARTS.DIM_OP_COMPANY_TYPE T3  " +
                        " WHERE T.COMPANY_ID = T1.COMPANY_ID  " +
                        "   AND T1.DEPT_ID = T2.DEPT_ID  " +
                        "   AND T1.COMPANY_TYPE = T3.TYPE_ID  " +
                        "   AND T2.DEPT_ID = " + dept +
                        "   AND T.DATE_ID =" + year +
                        "   AND T3.TYPE_ID =" + type;
            }
            //11-污水处理工艺
            if (type == 11) {
                sql = "SELECT T4.TYPE_NAME, COUNT(1)  " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE   T,  " +
                        "     ECHARTS.DIM_OP_COMPANY          T1,  " +
                        "     ECHARTS.DIM_DEPT_OP             T2,  " +
                        "     ECHARTS.DIM_OP_COMPANY_TYPE     T3,  " +
                        "     ECHARTS.DIM_OP_SEWAGE_PROCESS_TYPE T4  " +
                        " WHERE T.COMPANY_ID = T1.COMPANY_ID  " +
                        "   AND T1.DEPT_ID = T2.DEPT_ID  " +
                        "   AND T.PROCESS_TYPE = T4.TYPE_ID  " +
                        "   AND T1.COMPANY_TYPE = T3.TYPE_ID  " +
                        "   AND T2.DEPT_ID =  " + dept +
                        "   AND T.DATE_ID = " + year +
                        "   AND T3.TYPE_ID = 2  " +
                        " GROUP BY T4.TYPE_NAME";
            }
            //12-污水排放标准
            if (type == 12) {
                sql = "SELECT T4.STANDARD_NAME, COUNT(1)  " +
                        "  FROM ECHARTS.DM_OP_YR_BASE_SCALE        T,  " +
                        "     ECHARTS.DIM_OP_COMPANY               T1,  " +
                        "     ECHARTS.DIM_DEPT_OP                  T2,  " +
                        "     ECHARTS.DIM_OP_COMPANY_TYPE          T3,  " +
                        "     ECHARTS.DIM_OP_SEWAGE_STANDARD T4  " +
                        " WHERE T.COMPANY_ID = T1.COMPANY_ID  " +
                        "   AND T1.DEPT_ID = T2.DEPT_ID  " +
                        "   AND T.EFFLUENT_STANDARD = T4.STANDARD_ID  " +
                        "   AND T1.COMPANY_TYPE = T3.TYPE_ID  " +
                        "   AND T2.DEPT_ID = " + dept +
                        "   AND T.DATE_ID = " + year +
                        "   AND T3.TYPE_ID = 2  " +
                        " GROUP BY T4.STANDARD_NAME";
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

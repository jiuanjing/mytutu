<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.gson.Gson" %>
<%--
  Created by wang at 2016/11/16 13:54
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    DBOperation db = new DBOperation(true);
    if (db.dbOpen()) {
        try {
            String year = request.getParameter("year");
            String dept = request.getParameter("dept");
            //1-污水工艺类型  2-污水排放标准
            String type = request.getParameter("type");

            String sql = "";
            if ("1".equals(type)) {
                sql = "SELECT V1.TYPE_NAME, NVL(V2.SCALE, 0), NVL(V2.QUANTITY, 0)  " +
                        "  FROM ECHARTS.DIM_OP_SEWAGE_PROCESS_TYPE V1,  " +
                        "    (SELECT T3.TYPE_NAME, SUM(T.SCALE) SCALE, SUM(T.QUANTITY) QUANTITY  " +
                        "    FROM ECHARTS.DM_OP_YR_BASE_SCALE     T,  " +
                        "      ECHARTS.DIM_OP_COMPANY          T1,  " +
                        "      ECHARTS.DIM_DEPT_OP             T2,  " +
                        "      ECHARTS.DIM_OP_SEWAGE_PROCESS_TYPE T3  " +
                        "   WHERE T.DATE_ID =" + year +
                        "     AND T1.COMPANY_ID = T.COMPANY_ID  " +
                        "     AND T1.DEPT_ID = T2.DEPT_ID  " +
                        "     AND T.PROCESS_TYPE = T3.TYPE_ID  " +
                        "     AND T1.DEPT_ID =" + dept +
                        "   GROUP BY T3.TYPE_NAME) V2  " +
                        " WHERE V1.TYPE_NAME = V2.TYPE_NAME(+)";
            }

            if ("2".equals(type)) {
                sql = "SELECT V1.STANDARD_NAME, NVL(V2.SCALE, 0), NVL(V2.QUANTITY, 0)  " +
                        "  FROM ECHARTS.DIM_OP_SEWAGE_STANDARD V1,  " +
                        "     (SELECT T3.STANDARD_NAME standard_name, SUM(T.SCALE) SCALE, SUM(T.QUANTITY) QUANTITY  " +
                        "      FROM ECHARTS.DM_OP_YR_BASE_SCALE     T,  " +
                        "         ECHARTS.DIM_OP_COMPANY          T1,  " +
                        "         ECHARTS.DIM_DEPT_OP             T2,  " +
                        "         ECHARTS.DIM_OP_SEWAGE_STANDARD T3  " +
                        "   WHERE T.DATE_ID =" + year +
                        "       AND T1.COMPANY_ID = T.COMPANY_ID  " +
                        "       AND T1.DEPT_ID = T2.DEPT_ID  " +
                        "       AND T.EFFLUENT_STANDARD = T3.STANDARD_ID  " +
                        "     AND T1.DEPT_ID =" + dept +
                        "     GROUP BY T3.STANDARD_NAME) V2  " +
                        " WHERE V1.Standard_Name = V2.standard_name(+)";
            }

            Map<String, List<String>> dataMap = new HashMap<String, List<String>>();

            ResultSet rs = db.executeQuery(sql);
            try {
                List<String> list1 = new ArrayList<String>();
                List<String> list2 = new ArrayList<String>();
                List<String> list3 = new ArrayList<String>();

                while (rs.next()) {
                    list1.add(rs.getString(1));
                    list2.add(rs.getString(2));
                    list3.add(rs.getString(3));
                }
                dataMap.put("name", list1);
                dataMap.put("scale", list2);
                dataMap.put("quantity", list3);
            } catch (SQLException e) {
                e.printStackTrace();
            }
            Gson gson = new Gson();
            String s = gson.toJson(dataMap);
            out.print(s);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            db.dbClose();
        }
    }
%>

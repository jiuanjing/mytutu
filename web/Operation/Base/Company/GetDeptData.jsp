<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="userInfo" class="com.bws.util.UserInfo" scope="session"/>
<%
    DBOperation dbOperation = new DBOperation(true);
    if (dbOperation.dbOpen()) {
        try {
            String sql = "";
            int deptId = userInfo.getDeptIDOp();
            if (deptId == 0) {
                sql = "SELECT T.DEPT_ID, T.DEPT_NAME FROM ECHARTS.DIM_DEPT_OP T" +
                        " order by t.dept_id";
                deptId = 1;
            } else {
                sql = "SELECT T.DEPT_ID, T.DEPT_NAME FROM ECHARTS.DIM_DEPT_OP T" +
                        " where t.dept_id = " + deptId + " order by t.dept_id";
            }

            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();

            ResultSet resultSet = dbOperation.executeQuery(sql);
            while (resultSet.next()) {
                Map<String, Object> map = new HashMap<String, Object>();
                if (String.valueOf(deptId).endsWith(resultSet.getString(1))) {
                    map.put("id", resultSet.getString(1));
                    map.put("text", resultSet.getString(2));
                    map.put("selected", true);
                } else {
                    map.put("id", resultSet.getString(1));
                    map.put("text", resultSet.getString(2));
                }
                list.add(map);
            }
            Gson gson = new Gson();
            String s = gson.toJson(list);
            out.write(s);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            dbOperation.dbClose();
        }
    }
%>

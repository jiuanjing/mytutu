<%@ page import="com.bws.dbOperation.DBOperation" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %><%--
获取登陆用户的大区选择信息
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="userInfo" class="com.bws.util.UserInfo" scope="session"/>
<%
    int deptId = userInfo.getDeptIDOp();
    String sql;
    if (deptId == 0) {
        sql = "SELECT T.DEPT_ID, T.DEPT_NAME" +
                "  FROM ECHARTS.DIM_DEPT_OP T" +
                " ORDER BY T.DEPT_ID";
    } else {
        sql = "SELECT T.DEPT_ID, T.DEPT_NAME" +
                "  FROM ECHARTS.DIM_DEPT_OP T" +
                " WHERE T.DEPT_ID = " + deptId +
                " ORDER BY T.DEPT_ID";
    }

    DBOperation dbOperation = new DBOperation(true);

    Map<String, List<String>> dataMap = new HashMap<String, List<String>>();
    List<String> idLists = new ArrayList<String>();
    List<String> nameLists = new ArrayList<String>();
    if (dbOperation.dbOpen()) {
        ResultSet resultSet = dbOperation.executeQuery(sql);
        if (resultSet != null) {
            try {
                while (resultSet.next()) {
                    idLists.add(resultSet.getString(1));
                    nameLists.add(resultSet.getString(2));
                }
                dataMap.put("id", idLists);
                dataMap.put("name", nameLists);
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                dbOperation.dbClose();
            }
            Gson gson = new Gson();
            String s = gson.toJson(dataMap);
            out.write(s);
        }
    }
%>


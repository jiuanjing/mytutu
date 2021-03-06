<%
    /*********************************************************************************************************************
     *程序名称：AutoDeptList.jsp
     *功能描述：从数据库中动态取得数据，并返回  用于模糊查询大区名称
     *编写人：cjl
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.Date,com.bws.util.*,java.util.*,com.google.gson.Gson,java.sql.*,com.bws.dbOperation.*,com.bws.tools.*" %>
<jsp:useBean id="userInfo" class="com.bws.util.UserInfo" scope="session"/>
<%

    //实例化数据库链接
    DBOperation db = new DBOperation(true);
    //打开数据库链接
    if (db.dbOpen()) {
        try {
            //查询用户所在大区
            //用户dept_id对应DEPARTMENT表，在查出dept_id_op则是对应数据dim_op_dept表id，根据此ID过滤大区数据
            int dept_id = userInfo.getDeptID();
            String sql4dept = "select a.dept_id_op from bim.department a where a.dept_id = " + dept_id;
            ResultSet rs = null;
            rs = db.executeQuery(sql4dept);
            if (rs == null) {
                throw new Exception("对不起！系统在查询数据库时出错");
            }
            //当前用户对应的部门ID
            int deptId = 0;
            rs.last();//定位到最后一条记录
            int intRowCount0 = rs.getRow();//取总的记录数
            if (intRowCount0 > 0) {
                rs.absolute(1);
                while (!rs.isAfterLast()) {
                    deptId = rs.getInt(1);
                    rs.next();
                }
            }
            //获取分析的数据库表的名字
            String tableName = request.getParameter("tableName").trim();
            String sqlstr = "";
            String where = "";
            if (deptId > 0) {
                sqlstr = "select a.dept_id , a.dept_name from echarts." + tableName + " a where a.status = 1 and a.dept_id = " + deptId + "  order by a.order_no";
            } else {
                sqlstr = "select a.dept_id , a.dept_name from echarts." + tableName + " a where a.status = 1  order by a.order_no";
            }
            //System.out.print(sqlstr);
            rs = null;
            rs = db.executeQuery(sqlstr);//通过数据库访问程序返回一个可滚动的记录集

            if (rs == null) {
                throw new Exception("对不起！系统在查询数据库时出错");
            }
            rs.last();//定位到最后一条记录
            int intRowCount = rs.getRow();//取总的记录数
            Gson gson = new Gson();
            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
            //拼返回串
            String str_return = "";
            if (intRowCount > 0) {
                rs.absolute(1);
                while (!rs.isAfterLast()) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    map.put("deptId", rs.getString(1));
                    map.put("deptName", rs.getString(2));
                    map.put("fullPinyin", PinYinUtil.getPinYin(rs.getString(2)));//
                    map.put("shortPinyin", PinYinUtil.getPinYinHeadChar(rs.getString(2)));
                    list.add(map);
                    rs.next();
                }
            }
            str_return = gson.toJson(list);
            out.print(str_return);//ajax返回的结果

        } catch (Exception e) {
            throw e;
        } finally {
            db.dbClose();
        }
    } else {
        throw new Exception("对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！");
    }

%>
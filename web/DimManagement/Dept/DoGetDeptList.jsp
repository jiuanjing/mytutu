<%
    /*********************************************************************************************************************
     *功能描述：从数据库中动态取得数据，并返回
     *编写人：cjl
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,com.google.gson.Gson,java.sql.ResultSet,java.util.ArrayList,java.util.HashMap,java.util.List,java.util.Map" %>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            String bu_name = request.getParameter("dept_name").trim();
            String order = request.getParameter("order");
            String sort = request.getParameter("sort");
            //当前页
            int pageNum = Integer.valueOf(request.getParameter("page"));
            //每页显示数
            int rows = Integer.valueOf(request.getParameter("rows"));

            sqlstr = "select t.dept_id,t.dept_name,t.brief_name,t.dept_code,t.status,t.order_no from echarts.dim_dept t where 1=1";

            String where = "";
            if (bu_name != null && !(bu_name.equals(""))) {
                String name = new String(bu_name.getBytes("ISO8859-1"), "UTF-8");
                where += " and t.dept_name like '%" + name + "%'";
            }
            sqlstr = sqlstr + where + " order by t." + sort + " " + order;

            //System.out.println(sqlstr);

            ResultSet rs = null;
            rs = db.executeQuery(sqlstr);//通过数据库访问程序返回一个可滚动的记录集

            if (rs == null) {
                throw new Exception("对不起！系统在查询数据库时出错");
            }

            rs.last();//定位到最后一条记录
            int intRowCount = rs.getRow();//取总的记录数

            Gson gson = new Gson();
            Map<String, Object> mapAll = new HashMap<String, Object>();
            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
            //拼返回串
            String str_return = "";
            if (intRowCount > 0) {
                int absPage = (pageNum - 1) * rows + 1;
                rs.absolute(absPage);
                int absRows = 0;
                for (int i = 0; i < rows; i++) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    map.put("dept_id", rs.getString(1));
                    map.put("dept_name", rs.getString(2));
                    map.put("brief_name", rs.getString(3));
                    map.put("dept_code", rs.getString(4));
                    map.put("status", rs.getString(5));
                    map.put("order_no", rs.getString(6));
                    list.add(map);
                    if (rs.isLast()) {
                        break;
                    } else {
                        rs.next();
                    }

                }
            }
            mapAll.put("total", intRowCount);
            mapAll.put("rows", list);
            str_return = gson.toJson(mapAll);
            out.println(str_return);//ajax返回的结果

        } catch (Exception e) {
            throw e;
        } finally {
            db.dbClose();
        }
    } else {
        throw new Exception("对不起！系统无法与数据库建立链接，请稍后再试或与系统管理员联系！");
    }
%>
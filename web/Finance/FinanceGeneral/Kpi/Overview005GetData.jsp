<%
    /*********************************************************************************************************************
     *功能描述：从数据库中动态取得数据，并返回
     *编写人：cjl
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,com.bws.util.DateTool" %>
<%@ page import="java.sql.ResultSet" %>
<%
    //实例化数据库链接

    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            String date = request.getParameter("date").trim();
            String sort = request.getParameter("sort").trim();
            //echarts.dm_profitability
            String tableName = "";

            String where = "";
            if (date != null && !(date.equals(""))) {
                if ("0".equals(sort)) {
                    tableName = "echarts.dm_profitability";
                    int begin_date_int = Integer.valueOf((Integer.valueOf(date.substring(0, 4)) - 1) + date.substring(5, 7));
                    where += " and date_id >" + begin_date_int;
                    int end_date_int = Integer.valueOf(date.substring(0, 4) + date.substring(5, 7));
                    where += " and date_id <=" + end_date_int;
                }
                if ("1".equals(sort)) {
                    tableName = "echarts.dm_profitability_q";
                    int begin_date_int = Integer.valueOf((Integer.valueOf(date.substring(0, 4)) - 1) + "01");
                    where += " and date_id >" + begin_date_int;
                    int end_date_int = Integer.valueOf(date.substring(0, 4) + DateTool.getSeason(date.substring(5, 7)));
                    where += " and date_id <=" + end_date_int;
                }
                if ("2".equals(sort)) {
                    tableName = "echarts.dm_profitability_y";
                }
            }
            sqlstr = "select date_id,roe_parent from " + tableName + " where company_id=1";
            sqlstr = sqlstr + where + " order by date_id";

            ResultSet rs = null;
            rs = db.executeQuery(sqlstr);//通过数据库访问程序返回一个可滚动的记录集
            // System.out.println(sqlstr);
            if (rs == null) {
                throw new Exception("对不起！系统在查询数据库时出错");
            }

            rs.last();//定位到最后一条记录
            int intRowCount = rs.getRow();//取总的记录数


            //拼返回串
            String str_return = "";

            if (intRowCount > 0) {
                str_return = "[";
                rs.absolute(1);
                while (!rs.isAfterLast()) {
                    str_return = str_return + "'" + rs.getString(1) + ":" + rs.getString(2) + "',";
                    rs.next();
                }
                str_return = str_return.substring(0, str_return.length() - 1).trim() + "]";
            }
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
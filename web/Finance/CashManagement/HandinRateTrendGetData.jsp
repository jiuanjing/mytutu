<%
    /*********************************************************************************************************************
     *程序名称：HandinRateTrendGetData.jsp
     *功能描述：从数据库中动态取得数据，并返回
     *编写人：cjl
     *编写时间：2015-10-22
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
            //获取开始时间，结束时间
            String begin_date = request.getParameter("begin_date").trim();
            String end_date = request.getParameter("end_date").trim();

            String where = "";
            if (request.getParameter("CompanyID") != null && !(request.getParameter("CompanyID").equals(""))) {
                where = " where company_id=" + request.getParameter("CompanyID").trim();
            } else {
                where = " where company_id=1";
            }
            String types = request.getParameter("types").trim();
            String tableName = "";

            if ("0".equals(types)) {
                //范围为月
                tableName = "echarts.dm_monetary_handin";
                if (begin_date != null && !(begin_date.equals(""))) {
                    int begin_date_int = Integer.valueOf(begin_date.substring(0, 4) + begin_date.substring(5, 7));
                    where += " and date_id >=" + begin_date_int;
                }
                if (end_date != null && !(end_date.equals(""))) {
                    int end_date_int = Integer.valueOf(end_date.substring(0, 4) + end_date.substring(5, 7));
                    where += " and date_id <=" + end_date_int;
                }
            }
            if ("1".equals(types)) {
                //范围为季度
                tableName = "echarts.dm_monetary_handin_q";
                if (begin_date != null && !(begin_date.equals(""))) {
                    int begin_date_int = Integer.valueOf(begin_date.substring(0, 4)
                            + DateTool.getSeason(begin_date.substring(5, 7)));
                    where += " and date_id >=" + begin_date_int;
                }
                if (end_date != null && !(end_date.equals(""))) {
                    int end_date_int = Integer.valueOf(end_date.substring(0, 4)
                            + DateTool.getSeason(end_date.substring(5, 7)));
                    where += " and date_id <=" + end_date_int;
                }
            }
            if ("2".equals(types)) {
                //范围为年
                tableName = "echarts.dm_monetary_handin_y";
                if (begin_date != null && !(begin_date.equals(""))) {
                    int begin_date_int = Integer.valueOf(begin_date.substring(0, 4));
                    where += " and date_id >=" + begin_date_int;
                }
                if (end_date != null && !(end_date.equals(""))) {
                    int end_date_int = Integer.valueOf(end_date.substring(0, 4));
                    where += " and date_id <=" + end_date_int;
                }
            }
            sqlstr = "select date_id,handin_rate from " + tableName;
            sqlstr = sqlstr + where + " order by date_id";

            ResultSet rs = null;
            rs = db.executeQuery(sqlstr);//通过数据库访问程序返回一个可滚动的记录集

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
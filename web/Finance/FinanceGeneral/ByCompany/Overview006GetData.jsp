<%
    /*********************************************************************************************************************
     *功能描述：从数据库中动态取得数据，并返回
     *编写人：cjl
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,java.sql.ResultSet" %>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            //获取开始时间，结束时间
            String date = request.getParameter("date").trim();
            String where = "";
            if (request.getParameter("CompanyID") != null && !(request.getParameter("CompanyID").equals(""))) {
                where = " where company_id=" + request.getParameter("CompanyID").trim();
            } else {
                where = " where company_id=9";
            }
            if (date != null && !(date.equals(""))) {
                //比较的是全年的值，所以无需修改
                int date_int = Integer.valueOf(Integer.valueOf(date.substring(0, 4)) + "12");

                where += " and date_id =" + date_int;
            }

            sqlstr = "select date_id,round(OPERATING_REVENUE/10000,2),round(OPERATING_REVENUE_LY/10000,2)," +
                    "round((OPERATING_REVENUE-OPERATING_REVENUE_LY)/10000,2),round(OPERATING_REVENUE_DIF_PRICE/10000" +
                    ",2),round(OPERATING_REVENUE_DIF_QUANTITY/10000,2) from echarts.dm_profitability";

            sqlstr = sqlstr + where + " order by date_id";
            //System.out.println(sqlstr);
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

                    str_return = str_return + "'" + rs.getString(1) + ":" + rs.getString(2) + ":" + rs.getString(3) + ":" + rs.getString(4) + ":" + rs.getString(5) + ":" + rs.getString(6) + "',";
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
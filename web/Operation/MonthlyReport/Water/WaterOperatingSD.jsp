<%
    /*********************************************************************************************************************
     *功能描述：存储供水公司 运营分析 原因说明
     *编写人：cjl
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.Date,java.util.*,com.google.gson.Gson,java.sql.*,com.bws.dbOperation.*,com.bws.tools.*,com.bws.util.*,java.text.DecimalFormat" %>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String CompanyID = request.getParameter("CompanyID");
            String date = request.getParameter("date");
            String waterFee = new String(request.getParameter("waterFee").getBytes("ISO8859-1"), "UTF-8");
            String receivable = new String(request.getParameter("receivable").getBytes("ISO8859-1"), "UTF-8");
            String profit = new String(request.getParameter("profit").getBytes("ISO8859-1"), "UTF-8");
            String operatingProfit = new String(request.getParameter("operatingProfit").getBytes("ISO8859-1"), "UTF-8");
            String sqlstr = "";
            sqlstr = "update echarts.DM_OP_MR_REASON_W t set REASON_OP_WATER_FEE='" + waterFee + "',REASON_OP_RECEIVABLE='" + receivable + "',REASON_OP_PROFIT='" + profit + "',REASON_OP_OPERATING_PROFIT='" + operatingProfit + "' where 1=1";
            String where = "";
            date = date.substring(0, 4) + date.substring(5, 7);
            where += " and t.report_date =" + date;
            where += " and t.company_id =" + CompanyID;
            sqlstr += where;
//            System.out.println(sqlstr);
            int re = 0;
            re = db.executeUpdate(sqlstr);
            db.executeCommit();//提交事务
            String str_return = "";
            if (re < 1) {
                str_return = "对不起！系统在更新数据时出错，请重试或与系统管理员联系！";
            } else {
                str_return = "您好，更新原因说明成功！";
            }
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
<%
    /*********************************************************************************************************************
     *程序名称：PPIRWarningGetData.jsp
     *功能描述：从数据库中动态取得数据，并返回
     *编写人：cjl
     *编写时间：2015-10-26
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,com.bws.util.DateTool,com.google.gson.Gson,java.sql.ResultSet,java.util.ArrayList,java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            //获取日期
            String date = request.getParameter("date").trim();

            String where = "";
            if (request.getParameter("CompanyID") != null && !(request.getParameter("CompanyID").equals(""))) {
                where = " where company_id=" + request.getParameter("CompanyID").trim();
            } else {
                //默认公司ID为1-首创
                where = " where company_id=1";
            }
            String types = request.getParameter("types").trim();
            String tableName = "";
            if ("0".equals(types)) {
                tableName = "echarts.dm_operating_growth";
                if (date != null && !(date.equals(""))) {
                    date = date.substring(0, 4) + date.substring(5, 7);
                    where += " and date_id =" + date;
                } else {
                    //默认日期为上个月
                    String date_str = DateTool.getPreMonDate02();
                    where += " and date_id =" + date_str;
                }
            }
            if ("1".equals(types)) {
                tableName = "echarts.dm_operating_growth_q";
                if (date != null && !(date.equals(""))) {
                    date = date.substring(0, 4) + DateTool.getSeason(date.substring(5, 7));
                    where += " and date_id =" + date;
                } else {
                    //默认日期为上季度
                    String date_str = DateTool.getPreSeason();
                    where += " and date_id =" + date_str;
                }
            }
            if ("2".equals(types)) {
                tableName = "echarts.dm_operating_growth_y";
                if (date != null && !(date.equals(""))) {
                    date = date.substring(0, 4);
                    where += " and date_id =" + date;
                } else {
                    //默认日期为去年
                    String date_str = DateTool.getPreYear();
                    where += " and date_id =" + date_str;
                }
            }
            sqlstr = "select ppir from " + tableName;

            sqlstr = sqlstr + where;

            ResultSet rs = null;
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
                    map.put("value", Float.parseFloat(rs.getString(1)));
                    map.put("name", "归属于母公司净利润增长率");
                    list.add(map);
                    rs.next();
                }
            }
            str_return = gson.toJson(list);
            //System.out.print(str_return);
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
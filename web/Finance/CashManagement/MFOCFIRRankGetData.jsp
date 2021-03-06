<%
    /*********************************************************************************************************************
     *程序名称：MFOCFIRRankGetData.jsp
     *功能描述：从数据库中动态取得数据，并返回
     *编写人：cjl
     *编写时间：2015-10-22
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,com.bws.util.DateTool,java.sql.ResultSet" %>
<jsp:useBean id="userInfo" class="com.bws.util.UserInfo" scope="session"/>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            //获取开始时间，结束时间
            String date = request.getParameter("date").trim();
            //获取target
            String target = request.getParameter("target").trim();

            String where = "";
            where += " and a." + target + " <> 0 and a.company_id > 2";
            String types = request.getParameter("types").trim();
            String tableName = "";
            if ("0".equals(types)) {
                tableName = "echarts.dm_monetary_fund";
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
                tableName = "echarts.dm_monetary_fund_q";
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
                tableName = "echarts.dm_monetary_fund_y";
                if (date != null && !(date.equals(""))) {
                    date = date.substring(0, 4);
                    where += " and date_id =" + date;
                } else {
                    //默认日期为去年
                    String date_str = DateTool.getPreYear();
                    where += " and date_id =" + date_str;
                }
            }
            String companyIDs = userInfo.getCompanyIds(userInfo.getUserID(), db);
            if (companyIDs.length() > 3) {
                where += " and a.company_id in " + companyIDs;
            }
            if ("mfocfir".equalsIgnoreCase(target)) {
                sqlstr = "select a.date_id,a." + target + ",b.brief_name from " + tableName + " a,echarts.dim_company_fn b where a.company_id = b.company_id ";

            } else {
                sqlstr = "select a.date_id,round(a." + target + "/10000,2),b.brief_name from " + tableName + " a,echarts.dim_company_fn b where a.company_id = b.company_id ";

            }
            sqlstr = sqlstr + where + " and b.status=1 and b.company_level=2 order by a." + target + " desc";

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
                    str_return = str_return + "'" + rs.getString(1) + ":" + rs.getString(2) + ":" + rs.getString(3) + "',";
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
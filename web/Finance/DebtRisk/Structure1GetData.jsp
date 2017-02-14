<%
    /*********************************************************************************************************************
     *程序名称：Structure1GetData.jsp
     *功能描述：从数据库中动态取得数据，并返回
     *编写人：cjl
     *编写时间：2015-10-21
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,com.bws.util.DateTool,com.google.gson.Gson,java.sql.ResultSet,java.util.ArrayList,java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<jsp:useBean id="userInfo" class="com.bws.util.UserInfo" scope="session"/>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            //获取日期yy-MM
            String date = request.getParameter("date").trim();
            //获取分析指标(数据库字段)
            String target = request.getParameter("target").trim();

            String where = "";

            //获取数据库表名
            String tableName = request.getParameter("tableName").trim();

            String types = request.getParameter("types").trim();
            if ("0".equals(types)) {
                tableName = "echarts.dm_debt_risk";
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
                tableName = "echarts.dm_debt_risk_q";
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
                tableName = "echarts.dm_debt_risk_y";
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
            sqlstr = "select c.dept_name,round(sum(a." + target + ")/10000,2) from " + tableName + " a ,echarts.dim_company_fn b,echarts.dim_dept c "
                    + "where a.company_id = b.company_id and B.FLAG_DISPLAY = 1 and b.dept_id = c.dept_id and a.company_id > 2";

            sqlstr = sqlstr + where + " and b.status=1 and b.company_level=2 and c.status=1 group by c.dept_name";
            //System.out.println(sqlstr);
            ResultSet rs = null;
            rs = db.executeQuery(sqlstr);//通过数据库访问程序返回一个可滚动的记录集

            if (rs == null) {
                throw new Exception("对不起！系统在查询数据库时出错");
            }

            rs.last();//定位到最后一条记录
            int intRowCount = rs.getRow();//取总的记录数

            Gson gson = new Gson();
            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
            List<Map<String, Object>> _list = new ArrayList<Map<String, Object>>();
            //拼返回串
            String str_return = "";

            if (intRowCount > 0) {
                rs.absolute(1);
                while (!rs.isAfterLast()) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    Float f = Float.parseFloat(rs.getString(2));
                    if (f < 0) {
                        map.put("value", f);
                        map.put("name", rs.getString(1));
                        _list.add(map);
                    } else {
                        map.put("value", f);
                        map.put("name", rs.getString(1));
                        list.add(map);
                    }
                    rs.next();
                }
            }
            Map<String, Object> map_all = new HashMap<String, Object>();
            map_all.put("positive", list);
            map_all.put("negative", _list);

            str_return = gson.toJson(map_all);
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
<%
    /*********************************************************************************************************************
     *功能描述：从数据库中动态取得数据，并返回
     *编写人：cjl
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,com.bws.util.DateTool,com.google.gson.Gson,java.sql.ResultSet,java.util.ArrayList,java.util.HashMap,java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            //获取开始时间，结束时间
            String date = request.getParameter("date").trim();
            String order = request.getParameter("order");
            String sort = request.getParameter("sort");

            String types = request.getParameter("types").trim();
            String tableName = "";

            String where = "";
            if ("0".equals(types)) {
                tableName = "echarts.dm_profitability";
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
                tableName = "echarts.dm_profitability_q";
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
                tableName = "echarts.dm_profitability_y";
                if (date != null && !(date.equals(""))) {
                    date = date.substring(0, 4);
                    where += " and date_id =" + date;
                } else {
                    //默认日期为去年
                    String date_str = DateTool.getPreYear();
                    where += " and date_id =" + date_str;
                }
            }

            sqlstr = "select t.company_id,t.brief_name,t.ROE from (select a.COMPANY_ID,b.brief_name," +
                    "a.ROE from " + tableName + " a,echarts.dim_company_fn b"
                    + " where a.company_id = b.company_id and B.FLAG_DISPLAY = 1 and  a.ROE <> 0 and a.company_id > 2";

            sqlstr = sqlstr + where + " and b.status=1  and b.bu_id = 5 and b.company_level=2 order by a." + sort + " " + order + ") t where rownum<=10";
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
                rs.absolute(1);
                while (!rs.isAfterLast()) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    map.put("CompanyId", rs.getString(1));
                    map.put("CompanyName", rs.getString(2));
                    map.put("roe", rs.getString(3));
                    list.add(map);
                    rs.next();
                }
            }
            mapAll.put("total", intRowCount);
            mapAll.put("rows", list);
            str_return = gson.toJson(mapAll);

            //System.out.println(date);
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
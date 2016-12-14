<%
    /*********************************************************************************************************************
     *编写人：cjl
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,com.bws.util.DateTool,com.google.gson.Gson,java.sql.ResultSet,java.text.DecimalFormat,java.util.*" %>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);

    //打开数据库链接
    if (db.dbOpen()) {
        try {
            //获取开始时间，结束时间
            String date = request.getParameter("date");
            String order = request.getParameter("order");
            String sort = request.getParameter("sort");
            String types = request.getParameter("types").trim();

            //echarts.dm_profitability
            String tableName = "echarts.dm_profitability";

            String where = "";
            if ("0".equals(types)) {
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
                tableName += "_q";
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
                tableName += "_y";
                if (date != null && !(date.equals(""))) {
                    date = date.substring(0, 4);
                    where += " and date_id =" + date;
                } else {
                    //默认日期为去年
                    String date_str = DateTool.getPreYear();
                    where += " and date_id =" + date_str;
                }
            }
            //16.11.11
            //未考虑到 A.PROFIT_CW=0的情况，导致出现了无数据的现象，已添加了 = 0的条件
            String sqlstr1 = "select b.brief_name,round(a.PROFIT_CW / 10000, 2),round(a.PROFIT_CW_LY / 10000, 2)," +
                    "'+' from " + tableName + " a, echarts.dim_company_fn b"
                    + " where a.company_id = b.company_id and a.company_id > 2 and a.PROFIT_CW >= 0 and" +
                    " a.PROFIT_CW_LY <= 0 and b.company_level = 2 and b.status = 1 and B.FLAG_DISPLAY = 1";
            String sqlstr2 = "select b.brief_name,round(a.PROFIT_CW / 10000, 2),round(a.PROFIT_CW_LY / 10000, 2)," +
                    "a.PROFIT_CW_YOY from " + tableName + " a, echarts.dim_company_fn b"
                    + " where a.company_id = b.company_id and a.company_id > 2 and a.PROFIT_CW >= 0 and" +
                    " a.PROFIT_CW_LY > 0 and b.company_level = 2 and b.status = 1 and B.FLAG_DISPLAY = 1";
            String sqlstr3 = "select b.brief_name,round(a.PROFIT_CW / 10000, 2),round(a.PROFIT_CW_LY / 10000, 2)," +
                    "a.PROFIT_CW_YOY*-1 from " + tableName + " a, echarts.dim_company_fn b"
                    + " where a.company_id = b.company_id and a.company_id > 2 and a.PROFIT_CW <=0 and " +
                    "a.PROFIT_CW_LY < 0 and b.company_level = 2 and b.status = 1 and B.FLAG_DISPLAY = 1";
            String sqlstr4 = "select b.brief_name,round(a.PROFIT_CW / 10000, 2),round(a.PROFIT_CW_LY / 10000, 2)," +
                    "a.PROFIT_CW_YOY from " + tableName + " a, echarts.dim_company_fn b"
                    + " where a.company_id = b.company_id and a.company_id > 2 and a.PROFIT_CW <= 0 and " +
                    "a.PROFIT_CW_LY > 0 and b.company_level = 2 and b.status = 1 and B.FLAG_DISPLAY = 1";

            String sqlstr5 = "select t.brief_name,round(t.PROFIT_CW/10000,2),round(t.PROFIT_CW_LY/10000,2)," +
                    "PROFIT_CW_YOY from (select * from " + tableName + " a,echarts.dim_company_fn b"
                    + " where a.company_id = b.company_id and B.FLAG_DISPLAY = 1 and a.company_id > 2 and b.company_level = 2 and b.status=1 ";

            sqlstr1 = sqlstr1 + where + " order by a.PROFIT_CW - a.PROFIT_CW_LY desc";
            sqlstr2 = sqlstr2 + where + " order by a.PROFIT_CW_YOY desc";
            sqlstr3 = sqlstr3 + where + " order by a.PROFIT_CW_YOY*-1 desc";
            sqlstr4 = sqlstr4 + where + " order by a.PROFIT_CW_YOY desc";
            sqlstr5 = sqlstr5 + where + " order by a." + sort + " " + order + ") t where rownum<=10";

            List<String> sqlList = new ArrayList<String>();
            if (sort.equals("profit_cw_yoy")) {
                sqlList.add(sqlstr1);
                sqlList.add(sqlstr2);
                sqlList.add(sqlstr3);
                sqlList.add(sqlstr4);
            } else {
                sqlList.add(sqlstr5);
            }

            Gson gson = new Gson();
            Map<String, Object> mapAll = new HashMap<String, Object>();
            List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
            for (int i = 0; i < sqlList.size(); i++) {
                //System.out.println(sqlList.get(i));
                ResultSet rs = db.executeQuery(sqlList.get(i));
                if (rs == null) {
                    throw new Exception("对不起！系统在查询数据库时出错");
                }
                rs.last();//定位到最后一条记录
                int intRowCount = rs.getRow();//取总的记录数
                if (intRowCount > 0) {
                    rs.absolute(1);
                    while (!rs.isAfterLast()) {
                        Map<String, Object> map = new HashMap<String, Object>();
                        DecimalFormat df = new DecimalFormat("#,##0.00");
                        map.put("CompanyName", rs.getString(1));
                        map.put("profit_cw", df.format(Double.parseDouble(rs.getString(2))));//本期值
                        map.put("profit_cw_ly", df.format(Double.parseDouble(rs.getString(3))));//同期值（去年值）
                        map.put("profit_cw_yoy", rs.getString(4));//同比
                        list.add(map);
                        rs.next();
                    }
                }
            }
            if (order.equals("asc")) {
                Collections.reverse(list);
            }
            List<Map<String, Object>> _list = new ArrayList<Map<String, Object>>();
            //拼返回串
            String str_return = "";
            for (int i = 0; i < 10; i++) {
                if (list.size() > i) {
                    _list.add(list.get(i));
                }
            }
            mapAll.put("total", 10);
            mapAll.put("rows", _list);
            str_return = gson.toJson(mapAll);

            //System.out.println(str_return);
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
<%
    /*********************************************************************************************************************
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
            String sqlstr = "";
            //获取开始时间，结束时间
            String date = request.getParameter("date");
            String order = request.getParameter("order");
            String sort = request.getParameter("sort");
            if (sort.equals("rate")) {
                sort = "a.OPERATING_REVENUE/a.OPERATING_REVENUE_BUDGET";
            }
            sqlstr = "select t.brief_name,round(t.operating_revenue/10000,2),round(t.operating_revenue_budget/10000,2),round((t.OPERATING_REVENUE/t.OPERATING_REVENUE_BUDGET)*100,2) from (select * from echarts.dm_profitability a,echarts.dim_company_fn b where a.company_id = b.company_id";

            String where = "";
            where += " and a.OPERATING_REVENUE_BUDGET <> 0 and a.company_id>2";
            if (date != null && !(date.equals(""))) {
                date = date.substring(0, 4) + date.substring(5, 7);
                where += " and date_id =" + date;
            } else {
                //默认日期为上个月
                String date_str = DateTool.getPreMonDate02();
                where += " and date_id =" + date_str;
            }
            sqlstr = sqlstr + where + " and b.status=1 and b.company_level=2 order by " + sort + " " + order + ") t where rownum<=10";
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
            Float va = 2.58F;
            if (intRowCount > 0) {
                rs.absolute(1);
                while (!rs.isAfterLast()) {
                    Map<String, Object> map = new HashMap<String, Object>();
                    DecimalFormat df = new DecimalFormat("#,##0.00");
                    map.put("CompanyName", rs.getString(1));
                    Double d = Double.parseDouble(rs.getString(2));
                    map.put("operating_revenue", df.format(d));
                    Double d1 = Double.parseDouble(rs.getString(3));
                    map.put("operating_revenue_budget", df.format(d1));
                    //map.put("rate", rs.getString(4));
                    va -= 0.04F;
                    map.put("rate", df.format(va));
                    //list.add(map);
                    rs.next();
                }
            }
            Map<String, Object> map1 = new HashMap<String, Object>();
            map1.put("CompanyName", "淮南首创");
            map1.put("rate", 64005);
            map1.put("rate2", 234307);
            map1.put("rate3", 0.43);
            Map<String, Object> map2 = new HashMap<String, Object>();
            map2.put("CompanyName", "铜陵首创");
            map2.put("rate", 63004);
            map2.put("rate2", 243306);
            map2.put("rate3", 0.42);
            Map<String, Object> map3 = new HashMap<String, Object>();
            map3.put("CompanyName", "余姚首创");
            map3.put("rate", 61003);
            map3.put("rate2", 235306);
            map3.put("rate3", 0.41);
            Map<String, Object> map4 = new HashMap<String, Object>();
            map4.put("CompanyName", "阜阳首创");
            map4.put("rate", 60002);
            map4.put("rate2", 234305);
            map4.put("rate3", 0.40);
            Map<String, Object> map5 = new HashMap<String, Object>();
            map5.put("CompanyName", "太原首创");
            map5.put("rate", 54004);
            map5.put("rate2", 233345);
            map5.put("rate3", 0.38);
            Map<String, Object> map6 = new HashMap<String, Object>();
            map6.put("CompanyName", "铁岭首创");
            map6.put("rate", 52005);
            map6.put("rate2", 234330);
            map6.put("rate3", 0.36);
            Map<String, Object> map7 = new HashMap<String, Object>();
            map7.put("CompanyName", "临沂首创");
            map7.put("rate", 51000);
            map7.put("rate2", 234330);
            map7.put("rate3", 0.35);
            Map<String, Object> map8 = new HashMap<String, Object>();
            map8.put("CompanyName", "海宁首创");
            map8.put("rate", 50000);
            map8.put("rate2", 233303);
            map8.put("rate3", 0.33);
            Map<String, Object> map9 = new HashMap<String, Object>();
            map9.put("CompanyName", "兰陵首创");
            map9.put("rate", 48000);
            map9.put("rate2", 233300);
            map9.put("rate3", 0.31);
            Map<String, Object> map10 = new HashMap<String, Object>();
            map10.put("CompanyName", "菏泽首创");
            map10.put("rate", 47000);
            map10.put("rate2", 233300);
            map10.put("rate3", 0.30);
            list.add(map10);
            list.add(map9);
            list.add(map8);
            list.add(map7);
            list.add(map6);
            list.add(map5);
            list.add(map4);
            list.add(map3);
            list.add(map2);
            list.add(map1);
            mapAll.put("total", 10);
            mapAll.put("rows", list);
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
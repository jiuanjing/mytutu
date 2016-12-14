<%
    /*********************************************************************************************************************
     *程序名称：AutoCompanyList.jsp
     *功能描述：从数据库中动态取得数据，并返回  用于模糊查询供水公司名称
     *编写人：cjl
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.util.Date,com.bws.util.*,java.util.*,com.google.gson.Gson,java.sql.*,com.bws.dbOperation.*,com.bws.tools.*" %>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);
    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            //获取分析的数据库表的名字
            String tableName = request.getParameter("tableName").trim();

            sqlstr = "select a.company_id , a.company_name from echarts." + tableName + " a where a.status = 1 and a.flag_water = 1 order by a.order_no";
            //System.out.print(sqlstr);
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
                    map.put("companyId", rs.getString(1));
                    map.put("companyName", rs.getString(2));
                    map.put("fullPinyin", PinYinUtil.getPinYin(rs.getString(2)));//
                    map.put("shortPinyin", PinYinUtil.getPinYinHeadChar(rs.getString(2)));
                    list.add(map);
                    rs.next();
                }
            }
            str_return = gson.toJson(list);
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
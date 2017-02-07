<%
    /*********************************************************************************************************************
     *程序名称：AutoCompanyList.jsp
     *功能描述：从数据库中动态取得数据，并返回  用于模糊查询公司名称
     *主要应用于财务分析模块，应用时，参数tableName："DIM_COMPANY_FN"
     *编写人：cjl
     *编写时间：2015-10-30
     **********************************************************************************************************************/
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="com.bws.dbOperation.DBOperation,com.bws.util.PinYinUtil,com.google.gson.Gson,java.sql.ResultSet,java.util.ArrayList,java.util.HashMap,java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    //实例化数据库链接
    DBOperation db = new DBOperation(true);
    //打开数据库链接
    if (db.dbOpen()) {
        try {
            String sqlstr = "";
            String isDisplay = request.getParameter("isDisplay");
            isDisplay = isDisplay == null ? "0" : "1";
            //获取分析的数据库表的名字
            String tableName = request.getParameter("tableName").trim();
            if ("1".equals(isDisplay)) {
                sqlstr = "select distinct company_id,company_name from echarts.dim_company_fn where status=1 " +
                        "and flag_display = 1";
            } else {
                sqlstr = "select a.company_id , a.company_name from echarts." + tableName + " a where a.status = 1";
            }
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
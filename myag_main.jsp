<%-- 共有カレンダーページ --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%

    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String session_id = (String)session.getAttribute("login_id");
    String yotei_ids = (String)session.getAttribute("yotei_id");
    String yotei_names = (String)session.getAttribute("yotei_name");
  	String favorite = request.getParameter("hit_flag");
  	if (session_id == null) {
  		response.sendRedirect("index.jsp");
  	}

    //現在の日付取得
    Date today = new Date();
    //Calendarクラスのオブジェクト生成
    Calendar calendar = Calendar.getInstance();
    //現在の日付設定
    calendar.setTime(today);
    //年、月、日の取得
    int year = calendar.get(Calendar.YEAR);
    int show_year = calendar.get(Calendar.YEAR);
    int month = calendar.get(Calendar.MONTH);
    int show_month = calendar.get(Calendar.MONTH);
    int day = calendar.get(Calendar.DATE);
    int show_day = calendar.get(Calendar.DATE);
    calendar.set(year,month,1);
    int ww = calendar.get(Calendar.DAY_OF_WEEK)-1;

    if (request.getParameter("month") != null) {
      if (!(request.getParameter("month").equals(month))) {
        year = Integer.valueOf(request.getParameter("year"));
        month = Integer.valueOf(request.getParameter("month"));
      }
    }
      if (month>11) {
        year = year+1;
        month = 0;
        calendar.set(year,month,1);
        ww = calendar.get(Calendar.DAY_OF_WEEK)-1;
      }else if(month<0){
        year = year-1;
        month = 11;
        calendar.set(year,month,1);
        ww = calendar.get(Calendar.DAY_OF_WEEK)-1;
      }else{
      month = month;
      calendar.set(year,month,1);
      ww = calendar.get(Calendar.DAY_OF_WEEK)-1;
      }

    //うるう年
    int a = year%4;
    int b = year%100;
    int c = year%400;
    int leap=0;
    if(a ==0 && b != 0 || c ==0){
      leap =29;
    }else{
      leap =28;
    }

    int tuki_max;

    if(month==0 || month==2 || month==4 || month==6 || month==7 || month==9 || month==11){
      tuki_max =31;
    }else if(month==3 || month==5 || month==8 || month==10){
      tuki_max =30;
    }else{
      tuki_max =leap;
    }

    int num[] = new int[37];
    Integer blank = 0;

    //配列へデータを入力
    for(int i=0;i<37;i++){
      if(ww>i){
        num[i] = blank;
      }else{
      num[i] = (i+1)-ww;
      }
    }
    for(int j=0;j<37;j++){
      if(num[j]>=32){
        num[j] = blank;
      }
    }


//--データベース--

//データベースに接続するために使用する変数宣言
Connection con = null;
Statement stmt = null;
StringBuffer SQL = null;
ResultSet rs = null;

//ローカルのMySQLに接続する設定
String USER ="root";
String PASSWORD = "";
String URL ="jdbc:mysql://localhost/agenda";

//サーバーのMySQLに接続する設定
/*String USER = "nhs90345";
String PASSWORD = "b19931230";
String URL ="jdbc:mysql://192.168.121.16/nhs90345db";*/

String DRIVER = "com.mysql.jdbc.Driver";

//確認メッセージ
StringBuffer ERMSG = null;
//ヒットフラグ
int hit_flag = 0;
int user_hit = 0;
int writing = 0;

//HashMap（1件分のデータを格納する連想配列）
HashMap<String,String> map = null;

//ArrayList（すべての件数を格納する配列）
ArrayList<HashMap> list = null;
list = new ArrayList<HashMap>();

try{	// ロードに失敗したときのための例外処理
  // JDBCドライバのロード
  Class.forName(DRIVER).newInstance();

  // Connectionオブジェクトの作成
  con = DriverManager.getConnection(URL,USER,PASSWORD);

  //Statementオブジェクトの作成
  stmt = con.createStatement();

  //SQLステートメントの作成（選択クエリ）
  SQL = new StringBuffer();

  SQL.append("select * from favorite_tbl where kaiin_id = '");
  SQL.append(session_id);
  SQL.append("' and yotei_id = '");
  SQL.append(yotei_ids);
  SQL.append("'");

  rs = stmt.executeQuery(SQL.toString());
  //入力したデータがデータベースに存在するか調べる
  if(rs.next()){  //存在する
    hit_flag=1;
  }else{  //存在しない(追加OK)
    hit_flag=0;
  }

  SQL = new StringBuffer();

  SQL.append("select kaiin_id from open_tbl where yotei_id =  '");
  SQL.append(yotei_ids);
  SQL.append("'and kaiin_id = '");
  SQL.append(session_id);
  SQL.append("'");

  rs = stmt.executeQuery(SQL.toString());
  //入力したデータがデータベースに存在するか調べる
  if(rs.next()){  //存在する
    user_hit=1;
  }else{  //存在しない
    user_hit=0;
  }

  SQL = new StringBuffer();

  SQL.append("select yotei_writing from open_tbl where yotei_id = '");
  SQL.append(yotei_ids);
  SQL.append("' and yotei_writing = '");
  SQL.append(1);
  SQL.append("'");
  rs = stmt.executeQuery(SQL.toString());
  System.out.println(SQL);
  //入力したデータがデータベースに存在するか調べる
  if(rs.next()){  //書き込み許可
    writing=1;
  }else{  //書き込み不可
    writing=0;
  }


  SQL = new StringBuffer();

  //SQL文の発行（選択クエリ）
  SQL.append("select open_tbl.kaiin_id,day,s_hour,s_mine,f_hour,f_mine,place,importance,yotei_name,kaiin_name from open_tbl,openyotei_tbl,kaiin_tbl where kaiin_tbl.kaiin_id = openyotei_tbl.kaiin_id and open_tbl.yotei_id = openyotei_tbl.yotei_id and openyotei_tbl.yotei_id = '");
  SQL.append(yotei_ids);
  SQL.append("' order by s_hour ASC,s_mine ASC");

  //SQL文の発行（選択クエリ）
  rs = stmt.executeQuery(SQL.toString());

  //抽出したデータを繰り返し処理で表示する。
  while(rs.next()){
      //DBのデータをHashMapへ格納する
    map = new HashMap<String,String>();
    map.put("kaiin_id",rs.getString("kaiin_id"));
    map.put("day",rs.getString("day"));
    map.put("s_hour",rs.getString("s_hour"));
    map.put("s_mine",rs.getString("s_mine"));
    map.put("f_hour",rs.getString("f_hour"));
    map.put("f_mine",rs.getString("f_mine"));
    map.put("place",rs.getString("place"));
    map.put("importance",rs.getString("importance"));
    map.put("yotei_name",rs.getString("yotei_name"));
    map.put("kaiin_name",rs.getString("kaiin_name"));

    //1件分のデータ(HashMap)をArrayListへ追加
    list.add(map);
  }
}	//tryブロック終了
catch(ClassNotFoundException e){
  ERMSG = new StringBuffer();
  ERMSG.append(e.getMessage());
}
catch(SQLException e){
  ERMSG = new StringBuffer();
  ERMSG.append(e.getMessage());
}
catch(Exception e){
  ERMSG = new StringBuffer();
  ERMSG.append(e.getMessage());
}

finally{
  //各種オブジェクトクローズ
    try{
      if(rs != null){
        rs.close();
      }
      if(stmt != null){
        stmt.close();
    }
      if(con != null){
        con.close();
    }
    }
  catch(SQLException e){
  ERMSG = new StringBuffer();
  ERMSG.append(e.getMessage());
  }
}
%>

<!DOCTYPE html>
<html>
  <meta charset="utf-8">

  <head>
    <title>メインページ</title>
  </head>

  <link rel="stylesheet" type="text/css" href="./css/open.css">

  <%
    if (favorite != null){
      if (favorite.equals("0")) {
  %>
    <body id="myag_main" onLoad="loadFavorite()">
  <%
      }
    }else{
  %>
    <body id="myag_main">
  <%
    }
  %>

    <div id="contents">

      <ul id="nav">
        <li id="today">
          <a href="./myag_main.jsp?today=<%= today %>">
            <span id="font1"><%= show_year %>/<%= show_month+1 %>/<%= show_day %></span>
            <span id="font2">今月のカレンダーに戻る</span>
          </a>
        </li>
        <%
          if (user_hit == 1) {
        %>
            <li id="myag"><a href="./main.jsp">メインに戻る</a></li>
        <%
          }else if (user_hit == 0) {
            if (hit_flag == 1) {
        %>
              <li id="myag_info">お気に入り登録済</li>
              <li class="info"><a href="./main.jsp">メインに戻る</a></li>
        <%
            }else{
        %>
            <li id="favo_info"><a href="#" onclick="ShowFavorite();">お気に入り登録</a></li>
            <form name="favorite_info" action="./session_Issue.jsp" method="post">
              <input type="hidden" name="favorite" value="favorite">
            </form>
            <li class="info"><a href="./main.jsp">メインに戻る</a></li>
        <%
            }
        %>
        <%
          }
        %>
      </ul>

    <table id="cal">
        <tr class="no-line">
          <td colspan="7" class="no-line">
            <h1 id="name">予定名「<%= yotei_names %>」
          </td>
        </tr>
        <tr border="0" cellspacing="1" cellpadding="1" bgcolor="#CCCCCC" style="font: 12px; color: #666666;">
            <td align="center" colspan="7" bgcolor="#EEEEEE" height="30" style="color: #666666;">
              <div class="tuki">
                <form method="post" action="./myag_main.jsp">
                  <input type="hidden" name="year" value="<%=year-1%>">
                  <input type="hidden" name="month" value="<%=month%>">
                  <input class="button" type="submit" value="前年">
                </form>
              </div>
              <div class="tuki">
                <form method="post" action="./myag_main.jsp">
                  <input type="hidden" name="year" value="<%=year%>">
                  <input type="hidden" name="month" value="<%=month-1%>">
                  <input class="button" type="submit" value="前月">
                </form>
              </div>
              <div class="tuki">
                <h1><%= year %>年<%= month+1 %>月</h1>
              </div>
              <div class="tuki">
                <form method="post" action="./myag_main.jsp">
                  <input type="hidden" name="year" value="<%=year%>">
                  <input type="hidden" name="month" value="<%=month+1%>">
                  <input class="button" type="submit" value="翌月">
                </form>
             </div>
             <div class="tuki">
               <form method="post" action="./myag_main.jsp">
                 <input type="hidden" name="year" value="<%=year+1%>">
                 <input type="hidden" name="month" value="<%=month%>">
                 <input class="button" type="submit" value="翌年">
               </form>
            </div>
          </tr>
          <tr>
              <td align="center" width="60" height="30" bgcolor="#FF3300" style="font-size: 20px; font-weight: bold; color: #FFFFFF;">日</td>
              <td align="center" width="60" bgcolor="#ffe4e1" style="font-size: 20px; font-weight: bold; color: #666666;">月</td>
              <td align="center" width="60" bgcolor="#ffe4e1" style="font-size: 20px; font-weight: bold; color: #666666;">火</td>
              <td align="center" width="60" bgcolor="#ffe4e1" style="font-size: 20px; font-weight: bold; color: #666666;">水</td>
              <td align="center" width="60" bgcolor="#ffe4e1" style="font-size: 20px; font-weight: bold; color: #666666;">木</td>
              <td align="center" width="60" bgcolor="#ffe4e1" style="font-size: 20px; font-weight: bold; color: #666666;">金</td>
              <td align="center" width="60" bgcolor="#00a1e9" style="font-size: 20px; font-weight: bold; color: #666666;">土</td>
          </tr>
          <tr>
            <%
            if (num[0]==0) {
            %>
            <td bgcolor="#FFFFFF"></td>
            <%
            }else{
            %><%
              String year0 = String.valueOf(year);
              String month0 = String.valueOf(month+1);
              String num0 = String.valueOf(num[0]);
              String day0 = year0+month0+num0;
              boolean flag0 = false;
              boolean flag0_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day0.equals(list.get(j).get("day"))) {
                  flag0 = true;
                }
                if (day0.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag0_1 = true;
                }
              }
            %>
            <%
              if (flag0 == true && flag0_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag0_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-01" style="color: #FF0000;">
                <%= num[0] %>
              </a>
              <div class="modal-wrapper" id="modal-01">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                  <h2><%= num[0] %>日の予定</h2>
                  <%
                    for(int j = 0; j < list.size(); j++){
                  %>
                  <%
                    if (day0.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                  %>
                    <a class="plans1" href="openschedule_check.jsp?day=<%= day0 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num0 %>">
                    <div class="yotei">
                      <table>
                        <tr class="no-line">
                          <td class="no-line">
                            <%= list.get(j).get("kaiin_name") %>
                          </td>
                          <td class="no-line2">
                            <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                            <%= list.get(j).get("place") %>
                          </td>
                        </tr>
                      </table>
                    </div>
                  </a>
                  <%
                    }
                    else if(day0.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                    {
                  %>
                  <a class="plans" href="openschedule_check.jsp?day=<%= day0 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num0 %>&year=<%= year %>&month=<%= month %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                    }
                  }if (writing == 1) {
                %>
                  <form action="./openschedule_make.jsp" method="post">
                    <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[0] %>">
                    <input type="submit" value="追加">
                  </form>
                <%
                  }
                %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[1]==0) {
            %>
            <td bgcolor="#FFFFFF"></td>
            <%
            }else{
            %><%
              String year1 = String.valueOf(year);
              String month1 = String.valueOf(month+1);
              String num1 = String.valueOf(num[1]);
              String day1 = year1+month1+num1;
              boolean flag1 = false;
              boolean flag1_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day1.equals(list.get(j).get("day"))) {
                  flag1 = true;
                }
                if (day1.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag1_1 = true;
                }
              }
            %>
            <%
              if (flag1 == true && flag1_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag1_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-02">
                <%= num[1] %>
              </a>
              <div class="modal-wrapper" id="modal-02">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[1] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day1.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day1 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num1 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day1.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day1 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num1 %>&year=<%= year %>&month=<%= month %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[1] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[2]==0) {
            %>
            <td bgcolor="#FFFFFF"></td>
            <%
            }else{
            %><%
              String year2 = String.valueOf(year);
              String month2 = String.valueOf(month+1);
              String num2 = String.valueOf(num[2]);
              String day2 = year2+month2+num2;
              boolean flag2 = false;
              boolean flag2_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day2.equals(list.get(j).get("day"))) {
                  flag2 = true;
                }
                if (day2.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag2_1 = true;
                }
              }
            %>
            <%
              if (flag2 == true && flag2_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag2_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-03">
                <%= num[2] %>
              </a>
              <div class="modal-wrapper" id="modal-03">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[2] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day2.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day2 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num2 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day2.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day2 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num2 %>&year=<%= year %>&month=<%= month %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[2] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[3]==0) {
            %>
            <td bgcolor="#FFFFFF"></td>
            <%
            }else{
            %><%
              String year3 = String.valueOf(year);
              String month3 = String.valueOf(month+1);
              String num3 = String.valueOf(num[3]);
              String day3 = year3+month3+num3;
              boolean flag3 = false;
              boolean flag3_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day3.equals(list.get(j).get("day"))) {
                  flag3 = true;
                }
                if (day3.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag3_1 = true;
                }
              }
            %>
            <%
              if (flag3 == true && flag3_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag3_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-04">
                <%= num[3] %>
              </a>
              <div class="modal-wrapper" id="modal-04">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[3] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day3.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day3 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num3 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day3.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day3 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num3 %>&year=<%= year %>&month=<%= month %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[3] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[4]==0) {
            %>
            <td bgcolor="#FFFFFF"></td>
            <%
            }else{
            %><%
              String year4 = String.valueOf(year);
              String month4 = String.valueOf(month+1);
              String num4 = String.valueOf(num[4]);
              String day4 = year4+month4+num4;
              boolean flag4 = false;
              boolean flag4_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day4.equals(list.get(j).get("day"))) {
                  flag4 = true;
                }
                if (day4.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag4_1 = true;
                }
              }
            %>
            <%
              if (flag4 == true && flag4_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag4_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-05">
                <%= num[4] %>
              </a>
              <div class="modal-wrapper" id="modal-05">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[4] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day4.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day4 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num4 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day4.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day4 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num4 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[4] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[5]==0) {
            %>
            <td bgcolor="#FFFFFF"></td>
            <%
            }else{
            %><%
              String year5 = String.valueOf(year);
              String month5 = String.valueOf(month+1);
              String num5 = String.valueOf(num[5]);
              String day5 = year5+month5+num5;
              boolean flag5 = false;
              boolean flag5_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day5.equals(list.get(j).get("day"))) {
                  flag5 = true;
                }
                if (day5.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag5_1 = true;
                }
              }
            %>
            <%
              if (flag5 == true && flag5_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag5_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-06">
                <%= num[5] %>
              </a>
              <div class="modal-wrapper" id="modal-06">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[5] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day5.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day5 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num5 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day5.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day5 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num5 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[5] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %><%
              String year6 = String.valueOf(year);
              String month6 = String.valueOf(month+1);
              String num6 = String.valueOf(num[6]);
              String day6 = year6+month6+num6;
              boolean flag6 = false;
              boolean flag6_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day6.equals(list.get(j).get("day"))) {
                  flag6 = true;
                }
                if (day6.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag6_1 = true;
                }
              }
            %>
            <%
              if (flag6 == true && flag6_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag6_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-07">
                <%= num[6] %>
              </a>
              <div class="modal-wrapper" id="modal-07">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[6] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day6.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day6 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num6 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day6.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                  <a class="plans" href="openschedule_check.jsp?day=<%= day6 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num6 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
                <%
                    }
                  }
                  if (writing == 1 || user_hit == 1) {
                %>
                  <form action="./openschedule_make.jsp" method="post">
                    <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[6] %>">
                    <input type="submit" value="追加">
                  </form>
                <%
                  }
                %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
          </tr>
          <tr><%
            String year7 = String.valueOf(year);
            String month7 = String.valueOf(month+1);
            String num7 = String.valueOf(num[7]);
            String day7 = year7+month7+num7;
            boolean flag7 = false;
            boolean flag7_1 = false;
            for(int j = 0; j < list.size(); j++){
              if (day7.equals(list.get(j).get("day"))) {
                flag7 = true;
              }
              if (day7.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
              {
                flag7_1 = true;
              }
            }
          %>
          <%
            if (flag7 == true && flag7_1 != true)
            {
          %>
              <td align="center" bgcolor="#fef263" style="color: #666666;">
          <%
            }
              else if(flag7_1 == true)
            {
          %>
              <td align="center" bgcolor="#ff7f50" style="color: #666666;">
          <%
            }
            else
            {
          %>
              <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
          <%
            }
          %>
              <a href="#modal-08" style="color: #FF0000;">
                <%= num[7] %>
              </a>
              <div class="modal-wrapper" id="modal-08">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[7] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day7.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day7 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num7 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day7.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day7 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num7 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[7] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year8 = String.valueOf(year);
              String month8 = String.valueOf(month+1);
              String num8 = String.valueOf(num[8]);
              String day8 = year8+month8+num8;
              boolean flag8 = false;
              boolean flag8_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day8.equals(list.get(j).get("day"))) {
                  flag8 = true;
                }
                if (day8.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag8_1 = true;
                }
              }
            %>
            <%
              if (flag8 == true && flag8_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag8_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-09">
                <%= num[8] %>
              </a>
              <div class="modal-wrapper" id="modal-09">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[8] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day8.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day8 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num8 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day8.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day8 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num8 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[8] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year9 = String.valueOf(year);
              String month9 = String.valueOf(month+1);
              String num9 = String.valueOf(num[9]);
              String day9 = year9+month9+num9;
              boolean flag9 = false;
              boolean flag9_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day9.equals(list.get(j).get("day"))) {
                  flag9 = true;
                }
                if (day9.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag9_1 = true;
                }
              }
            %>
            <%
              if (flag9 == true && flag9_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag9_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-10">
                <%= num[9] %>
              </a>
              <div class="modal-wrapper" id="modal-10">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[9] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day9.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day9 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num9 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day9.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day9 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num9 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[9] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year10 = String.valueOf(year);
              String month10 = String.valueOf(month+1);
              String num10 = String.valueOf(num[10]);
              String day10 = year10+month10+num10;
              boolean flag10 = false;
              boolean flag10_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day10.equals(list.get(j).get("day"))) {
                  flag10 = true;
                }
                if (day10.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag10_1 = true;
                }
              }
            %>
            <%
              if (flag10 == true && flag10_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag10_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-11">
                <%= num[10] %>
              </a>
              <div class="modal-wrapper" id="modal-11">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[10] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day10.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day10 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num10 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day10.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day10 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num10 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[10] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year11 = String.valueOf(year);
              String month11 = String.valueOf(month+1);
              String num11 = String.valueOf(num[11]);
              String day11 = year11+month11+num11;
              boolean flag11 = false;
              boolean flag11_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day11.equals(list.get(j).get("day"))) {
                  flag11 = true;
                }
                if (day11.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag11_1 = true;
                }
              }
            %>
            <%
              if (flag11 == true && flag11_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag11_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-12">
                <%= num[11] %>
              </a>
              <div class="modal-wrapper" id="modal-12">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[11] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day11.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day11 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num11 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day11.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day11 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num11 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[11] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year12 = String.valueOf(year);
              String month12 = String.valueOf(month+1);
              String num12 = String.valueOf(num[12]);
              String day12 = year12+month12+num12;
              boolean flag12 = false;
              boolean flag12_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day12.equals(list.get(j).get("day"))) {
                  flag12 = true;
                }
                if (day12.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag12_1 = true;
                }
              }
            %>
            <%
              if (flag12 == true && flag12_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag12_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-13">
                <%= num[12] %>
              </a>
              <div class="modal-wrapper" id="modal-13">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[12] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day12.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day12 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num12 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day12.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day12 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num12 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[12] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year13 = String.valueOf(year);
              String month13 = String.valueOf(month+1);
              String num13 = String.valueOf(num[13]);
              String day13 = year13+month13+num13;
              boolean flag13 = false;
              boolean flag13_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day13.equals(list.get(j).get("day"))) {
                  flag13 = true;
                }
                if (day13.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag13_1 = true;
                }
              }
            %>
            <%
              if (flag13 == true && flag13_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag13_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-14">
                <%= num[13] %>
              </a>
              <div class="modal-wrapper" id="modal-14">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[13] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day13.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day13 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num13 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day13.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day13 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num13 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[13] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
          </tr>
          <tr><%
            String year14 = String.valueOf(year);
            String month14 = String.valueOf(month+1);
            String num14 = String.valueOf(num[14]);
            String day14 = year14+month14+num14;
            boolean flag14 = false;
            boolean flag14_1 = false;
            for(int j = 0; j < list.size(); j++){
              if (day14.equals(list.get(j).get("day"))) {
                flag14 = true;
              }
              if (day14.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
              {
                flag14_1 = true;
              }
            }
          %>
          <%
            if (flag14 == true && flag14_1 != true)
            {
          %>
              <td align="center" bgcolor="#fef263" style="color: #666666;">
          <%
            }
              else if(flag14_1 == true)
            {
          %>
              <td align="center" bgcolor="#ff7f50" style="color: #666666;">
          <%
            }
            else
            {
          %>
              <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
          <%
            }
          %>
              <a href="#modal-15" style="color: #FF0000;">
                <%= num[14] %>
              </a>
              <div class="modal-wrapper" id="modal-15">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[14] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day14.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day14 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num14 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day14.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day14 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num14 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[14] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year15 = String.valueOf(year);
              String month15 = String.valueOf(month+1);
              String num15 = String.valueOf(num[15]);
              String day15 = year15+month15+num15;
              boolean flag15 = false;
              boolean flag15_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day15.equals(list.get(j).get("day"))) {
                  flag15 = true;
                }
                if (day15.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag15_1 = true;
                }
              }
            %>
            <%
              if (flag15 == true && flag15_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag15_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-16">
                <%= num[15] %>
              </a>
              <div class="modal-wrapper" id="modal-16">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[15] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day15.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day15 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num15 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day15.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day15 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num15 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[15] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year16 = String.valueOf(year);
              String month16 = String.valueOf(month+1);
              String num16 = String.valueOf(num[16]);
              String day16 = year16+month16+num16;
              boolean flag16 = false;
              boolean flag16_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day16.equals(list.get(j).get("day"))) {
                  flag16 = true;
                }
                if (day16.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag16_1 = true;
                }
              }
            %>
            <%
              if (flag16 == true && flag16_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag16_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-17">
                <%= num[16] %>
              </a>
              <div class="modal-wrapper" id="modal-17">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[16] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day16.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day16 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num16 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day16.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day16 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num16 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[16] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year17 = String.valueOf(year);
              String month17 = String.valueOf(month+1);
              String num17 = String.valueOf(num[17]);
              String day17 = year17+month17+num17;
              boolean flag17 = false;
              boolean flag17_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day17.equals(list.get(j).get("day"))) {
                  flag17 = true;
                }
                if (day17.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag17_1 = true;
                }
              }
            %>
            <%
              if (flag17 == true && flag17_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag17_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-18">
                <%= num[17] %>
              </a>
              <div class="modal-wrapper" id="modal-18">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[17] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day17.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day17 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num17 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day17.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day17 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num17 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[17] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year18 = String.valueOf(year);
              String month18 = String.valueOf(month+1);
              String num18 = String.valueOf(num[18]);
              String day18 = year18+month18+num18;
              boolean flag18 = false;
              boolean flag18_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day18.equals(list.get(j).get("day"))) {
                  flag18 = true;
                }
                if (day18.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag18_1 = true;
                }
              }
            %>
            <%
              if (flag18 == true && flag18_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag18_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-19">
                <%= num[18] %>
              </a>
              <div class="modal-wrapper" id="modal-19">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[18] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day18.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day18 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num18 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day18.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day18 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num18 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[18] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year19 = String.valueOf(year);
              String month19 = String.valueOf(month+1);
              String num19 = String.valueOf(num[19]);
              String day19 = year19+month19+num19;
              boolean flag19 = false;
              boolean flag19_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day19.equals(list.get(j).get("day"))) {
                  flag19 = true;
                }
                if (day19.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag19_1 = true;
                }
              }
            %>
            <%
              if (flag19 == true && flag19_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag19_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-20">
                <%= num[19] %>
              </a>
              <div class="modal-wrapper" id="modal-20">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[19] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day19.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day19 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num19 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day19.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day19 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num19 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[19] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year20 = String.valueOf(year);
              String month20 = String.valueOf(month+1);
              String num20 = String.valueOf(num[20]);
              String day20 = year20+month20+num20;
              boolean flag20 = false;
              boolean flag20_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day20.equals(list.get(j).get("day"))) {
                  flag20 = true;
                }
                if (day20.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag20_1 = true;
                }
              }
            %>
            <%
              if (flag20 == true && flag20_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag20_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-21">
                <%= num[20] %>
              </a>
              <div class="modal-wrapper" id="modal-21">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[20] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day20.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day20 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num20 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day20.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day20 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num20 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[20] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
          </tr>
          <tr><%
            String year21 = String.valueOf(year);
            String month21 = String.valueOf(month+1);
            String num21 = String.valueOf(num[21]);
            String day21 = year21+month21+num21;
            boolean flag21 = false;
            boolean flag21_1 = false;
            for(int j = 0; j < list.size(); j++){
              if (day21.equals(list.get(j).get("day"))) {
                flag21 = true;
              }
              if (day21.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
              {
                flag21_1 = true;
              }
            }
          %>
          <%
            if (flag21 == true && flag21_1 != true)
            {
          %>
              <td align="center" bgcolor="#fef263" style="color: #666666;">
          <%
            }
              else if(flag21_1 == true)
            {
          %>
              <td align="center" bgcolor="#ff7f50" style="color: #666666;">
          <%
            }
            else
            {
          %>
              <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
          <%
            }
          %>
              <a href="#modal-22" style="color: #FF0000;">
                <%= num[21] %>
              </a>
              <div class="modal-wrapper" id="modal-22">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[21] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day21.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day21 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num21 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day21.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day21 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num21 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[21] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year22 = String.valueOf(year);
              String month22 = String.valueOf(month+1);
              String num22 = String.valueOf(num[22]);
              String day22 = year22+month22+num22;
              boolean flag22 = false;
              boolean flag22_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day22.equals(list.get(j).get("day"))) {
                  flag22 = true;
                }
                if (day22.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag22_1 = true;
                }
              }
            %>
            <%
              if (flag22 == true && flag22_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag22_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-23">
                <%= num[22] %>
              </a>
              <div class="modal-wrapper" id="modal-23">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[22] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day22.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day22 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num22 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day22.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day22 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num22 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[22] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year23 = String.valueOf(year);
              String month23 = String.valueOf(month+1);
              String num23 = String.valueOf(num[23]);
              String day23 = year23+month23+num23;
              boolean flag23 = false;
              boolean flag23_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day23.equals(list.get(j).get("day"))) {
                  flag23 = true;
                }
                if (day23.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag23_1 = true;
                }
              }
            %>
            <%
              if (flag23 == true && flag23_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag23_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-24">
                <%= num[23] %>
              </a>
              <div class="modal-wrapper" id="modal-24">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[23] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day23.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day23 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num23 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day23.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day23 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num23 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[23] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year24 = String.valueOf(year);
              String month24 = String.valueOf(month+1);
              String num24 = String.valueOf(num[24]);
              String day24 = year24+month24+num24;
              boolean flag24 = false;
              boolean flag24_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day24.equals(list.get(j).get("day"))) {
                  flag24 = true;
                }
                if (day24.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag24_1 = true;
                }
              }
            %>
            <%
              if (flag24 == true && flag24_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag24_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-25">
                <%= num[24] %>
              </a>
              <div class="modal-wrapper" id="modal-25">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[24] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day24.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day24 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num24 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day24.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day24 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num24 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[24] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year25 = String.valueOf(year);
              String month25 = String.valueOf(month+1);
              String num25 = String.valueOf(num[25]);
              String day25 = year25+month25+num25;
              boolean flag25 = false;
              boolean flag25_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day25.equals(list.get(j).get("day"))) {
                  flag25 = true;
                }
                if (day25.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag25_1 = true;
                }
              }
            %>
            <%
              if (flag25 == true && flag25_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag25_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-26">
                <%= num[25] %>
              </a>
              <div class="modal-wrapper" id="modal-26">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[25] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day25.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day25 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num25 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day25.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day25 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num25 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[25] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year26 = String.valueOf(year);
              String month26 = String.valueOf(month+1);
              String num26 = String.valueOf(num[26]);
              String day26 = year26+month26+num26;
              boolean flag26 = false;
              boolean flag26_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day26.equals(list.get(j).get("day"))) {
                  flag26 = true;
                }
                if (day26.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag26_1 = true;
                }
              }
            %>
            <%
              if (flag26 == true && flag26_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag26_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-27">
                <%= num[26] %>
              </a>
              <div class="modal-wrapper" id="modal-27">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[26] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day26.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day26 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num26 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day26.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day26 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num26 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[26] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td><%
              String year27 = String.valueOf(year);
              String month27 = String.valueOf(month+1);
              String num27 = String.valueOf(num[27]);
              String day27 = year27+month27+num27;
              boolean flag27 = false;
              boolean flag27_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day27.equals(list.get(j).get("day"))) {
                  flag27 = true;
                }
                if (day27.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag27_1 = true;
                }
              }
            %>
            <%
              if (flag27 == true && flag27_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag27_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-28">
                <%= num[27] %>
              </a>
              <div class="modal-wrapper" id="modal-28">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[27] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day27.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day27 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num27 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day27.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day27 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num27 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[27] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
          </tr>
          <tr>
            <%
            if (num[28]==0 || tuki_max < num[28]) {
              %>
              </tr>
              <%
              }else{
              %><%
                String year28 = String.valueOf(year);
                String month28 = String.valueOf(month+1);
                String num28 = String.valueOf(num[28]);
                String day28 = year28+month28+num28;
                boolean flag28 = false;
                boolean flag28_1 = false;
                for(int j = 0; j < list.size(); j++){
                  if (day28.equals(list.get(j).get("day"))) {
                    flag28 = true;
                  }
                  if (day28.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                  {
                    flag28_1 = true;
                  }
                }
              %>
              <%
                if (flag28 == true && flag28_1 != true)
                {
              %>
                  <td align="center" bgcolor="#fef263" style="color: #666666;">
              <%
                }
                  else if(flag28_1 == true)
                {
              %>
                  <td align="center" bgcolor="#ff7f50" style="color: #666666;">
              <%
                }
                else
                {
              %>
                  <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
              <%
                }
              %>
              <a href="#modal-29" style="color: #FF0000;">
                <%= num[28] %>
              </a>
              <div class="modal-wrapper" id="modal-29">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[28] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day28.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day28 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num28 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day28.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day28 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num28 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[28] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[29]==0 || tuki_max < num[29]) {
            %>
            <td class="no-line"></td>
            <%
            }else{
            %><%
              String year29 = String.valueOf(year);
              String month29 = String.valueOf(month+1);
              String num29 = String.valueOf(num[29]);
              String day29 = year29+month29+num29;
              boolean flag29 = false;
              boolean flag29_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day29.equals(list.get(j).get("day"))) {
                  flag29 = true;
                }
                if (day29.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag29_1 = true;
                }
              }
            %>
            <%
              if (flag29 == true && flag29_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag29_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-30">
                <%= num[29] %>
              </a>
              <div class="modal-wrapper" id="modal-30">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[29] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day29.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day29 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num29 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day29.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day29 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num29 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[29] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[30]==0 || tuki_max < num[30]) {
            %>
            <td class="no-line"></td>
            <%
            }else{
            %><%
              String year30 = String.valueOf(year);
              String month30 = String.valueOf(month+1);
              String num30 = String.valueOf(num[30]);
              String day30 = year30+month30+num30;
              boolean flag30 = false;
              boolean flag30_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day30.equals(list.get(j).get("day"))) {
                  flag30 = true;
                }
                if (day30.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag30_1 = true;
                }
              }
            %>
            <%
              if (flag30 == true && flag30_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag30_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-31">
                <%= num[30] %>
              </a>
              <div class="modal-wrapper" id="modal-31">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[30] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day30.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day30 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num30 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day30.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day30 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num30 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[30] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[31]==0 || tuki_max < num[31]) {
            %>
            <td class="no-line"></td>
            <%
            }else{
            %><%
              String year31 = String.valueOf(year);
              String month31 = String.valueOf(month+1);
              String num31 = String.valueOf(num[31]);
              String day31 = year31+month31+num31;
              boolean flag31 = false;
              boolean flag31_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day31.equals(list.get(j).get("day"))) {
                  flag31 = true;
                }
                if (day31.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag31_1 = true;
                }
              }
            %>
            <%
              if (flag31 == true && flag31_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag31_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-32">
                <%= num[31] %>
              </a>
              <div class="modal-wrapper" id="modal-32">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[31] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day31.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day31 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num31 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day31.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day31 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num31 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[31] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[32]==0 || tuki_max < num[32]) {
            %>
            <td class="no-line"></td>
            <%
            }else{
            %><%
              String year32 = String.valueOf(year);
              String month32 = String.valueOf(month+1);
              String num32 = String.valueOf(num[32]);
              String day32 = year32+month32+num32;
              boolean flag32 = false;
              boolean flag32_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day32.equals(list.get(j).get("day"))) {
                  flag32 = true;
                }
                if (day32.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag32_1 = true;
                }
              }
            %>
            <%
              if (flag32 == true && flag32_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag32_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-33">
                <%= num[32] %>
              </a>
              <div class="modal-wrapper" id="modal-33">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[32] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day32.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day32 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num32 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day32.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day32 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num32 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[32] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[33]==0 || tuki_max < num[33]) {
            %>
            <td class="no-line"></td>
            <%
            }else{
            %><%
              String year33 = String.valueOf(year);
              String month33 = String.valueOf(month+1);
              String num33 = String.valueOf(num[33]);
              String day33 = year33+month33+num33;
              boolean flag33 = false;
              boolean flag33_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day33.equals(list.get(j).get("day"))) {
                  flag33 = true;
                }
                if (day33.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag33_1 = true;
                }
              }
            %>
            <%
              if (flag33 == true && flag33_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag33_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-34">
                <%= num[33] %>
              </a>
              <div class="modal-wrapper" id="modal-34">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[33] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day33.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day33 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num33 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day33.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day33 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num33 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[33] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[34]==0 || tuki_max < num[34]) {
            %>
            <td class="no-line"></td>
            <%
            }else{
            %><%
              String year34 = String.valueOf(year);
              String month34 = String.valueOf(month+1);
              String num34 = String.valueOf(num[34]);
              String day34 = year34+month34+num34;
              boolean flag34 = false;
              boolean flag34_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day34.equals(list.get(j).get("day"))) {
                  flag34 = true;
                }
                if (day34.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag34_1 = true;
                }
              }
            %>
            <%
              if (flag34 == true && flag34_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag34_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-35">
                <%= num[34] %>
              </a>
              <div class="modal-wrapper" id="modal-35">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[34] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <<%
                  if (day34.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day34 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num34 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day34.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day34 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num34 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[34] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
              </div>
            </div>
          </div>
            </td>
            <%
            }
            %>
          </tr>
          <tr>
          <%
          if (num[35]==0 || tuki_max < num[35]) {
            %>
            </tr>
            <%
            }else{
            %><%
              String year35 = String.valueOf(year);
              String month35 = String.valueOf(month+1);
              String num35 = String.valueOf(num[35]);
              String day35 = year35+month35+num35;
              boolean flag35 = false;
              boolean flag35_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day35.equals(list.get(j).get("day"))) {
                  flag35 = true;
                }
                if (day35.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag35_1 = true;
                }
              }
            %>
            <%
              if (flag35 == true && flag35_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag35_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-36" style="color: #FF0000;">
                <%= num[35] %>
              </a>
              <div class="modal-wrapper" id="modal-36">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[35] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day35.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day35 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num35 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day35.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day35 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num35 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[35] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
            <%
            if (num[36]==0 || tuki_max < num[36]) {
            %>
            </tr>
            <%
            }else{
            %><%
              String year36 = String.valueOf(year);
              String month36 = String.valueOf(month+1);
              String num36 = String.valueOf(num[36]);
              String day36 = year36+month36+num36;
              boolean flag36 = false;
              boolean flag36_1 = false;
              for(int j = 0; j < list.size(); j++){
                if (day36.equals(list.get(j).get("day"))) {
                  flag36 = true;
                }
                if (day36.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1"))
                {
                  flag36_1 = true;
                }
              }
            %>
            <%
              if (flag36 == true && flag36_1 != true)
              {
            %>
                <td align="center" bgcolor="#fef263" style="color: #666666;">
            <%
              }
                else if(flag36_1 == true)
              {
            %>
                <td align="center" bgcolor="#ff7f50" style="color: #666666;">
            <%
              }
              else
              {
            %>
                <td align="center" bgcolor="#FFFFFF" style="color: #666666;">
            <%
              }
            %>
              <a href="#modal-37">
                <%= num[36] %>
              </a>
              <div class="modal-wrapper" id="modal-37">
                <a href="#!" class="modal-overlay"></a>
                <div class="modal-window">
                  <div class="modal-content">
                <h2><%= num[36] %>日の予定</h2>
                <%
                  for(int j = 0; j < list.size(); j++){
                %>
                <%
                  if (day36.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("1")) {
                %>
                  <a class="plans1" href="openschedule_check.jsp?day=<%= day36 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num36 %>">
                  <div class="yotei">
                    <table>
                      <tr class="no-line">
                        <td class="no-line">
                          <%= list.get(j).get("kaiin_name") %>
                        </td>
                        <td class="no-line2">
                          <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                          <%= list.get(j).get("place") %>
                        </td>
                      </tr>
                    </table>
                  </div>
                </a>
                <%
                  }
                  else if(day36.equals(list.get(j).get("day")) && list.get(j).get("importance").equals("0"))
                  {
                %>
                <a class="plans" href="openschedule_check.jsp?day=<%= day36 %>&s_hour=<%= list.get(j).get("s_hour") %>&s_mine=<%= list.get(j).get("s_mine") %>&num=<%= num36 %>">
                <div class="yotei">
                  <table>
                    <tr class="no-line">
                      <td class="no-line">
                        <%= list.get(j).get("kaiin_name") %>
                      </td>
                      <td class="no-line2">
                        <%= list.get(j).get("s_hour") %>時<%= list.get(j).get("s_mine") %>分～
                        <%= list.get(j).get("place") %>
                      </td>
                    </tr>
                  </table>
                </div>
              </a>
              <%
                  }
                }if (writing == 1 || user_hit == 1) {
              %>
                <form action="./openschedule_make.jsp" method="post">
                  <input type="hidden" name="day" value="<%= year %><%= month+1 %><%= num[36] %>">
                  <input type="submit" value="追加">
                </form>
              <%
                }
              %>
                  <a href="#!" class="modal-close">×</a>
                </div>
              </div>
            </div>
            </td>
            <%
            }
            %>
          </tr>

        </table>

      </div>

        <div class="area" >
          <ul class="circles">
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
          </ul>
        </div >

  <script type="text/javascript" src="./js/main.js"></script>

  </body>
</html>

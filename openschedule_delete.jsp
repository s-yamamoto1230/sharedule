<%-- 公開カレンダーの予定削除 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
	//文字コードの指定
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

	//入力データ受信
    String session_id = (String)session.getAttribute("login_id");
    String dayStr  = request.getParameter("day");
    String s_hourStr  = request.getParameter("s_hour");
    String s_mineStr  = request.getParameter("s_mine");

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
//	String USER = "nhs90345";
//	String PASSWORD = "b19931230";
//  String URL ="jdbc:mysql://192.168.121.16/agenda";

	String DRIVER = "com.mysql.jdbc.Driver";

	//確認メッセージ
	StringBuffer ERMSG = null;

	//削除件数
	int del_count = 0;

	try{	// ロードに失敗したときのための例外処理
		// JDBCドライバのロード
		Class.forName(DRIVER).newInstance();

		// Connectionオブジェクトの作成
		con = DriverManager.getConnection(URL,USER,PASSWORD);

		//Statementオブジェクトの作成
		stmt = con.createStatement();

		  //SQLステートメントの作成（選択クエリ）
		  SQL = new StringBuffer();
		  //delete実行
		  SQL.append("delete from openyotei_tbl where day = '");
      SQL.append(dayStr);
      SQL.append("' and s_hour ='");
      SQL.append(s_hourStr);
      SQL.append("' and s_mine ='");
      SQL.append(s_mineStr);
      SQL.append("'");
      System.out.println(SQL.toString());
	      del_count = stmt.executeUpdate(SQL.toString());

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
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>予定削除</title>
<link rel="stylesheet" type="text/css" href="./css/info.css">
</head>
<body>
<%
	if(del_count == 0){  //処理失敗
%>
	<h1>削除NG</h1><br>
	  <%= "削除処理が失敗しました" %>
<%
	}else{  //削除OK
%>
	<h1>削除OK</h1><br>
	  <%= del_count + "件　削除が完了しました" %>
<%
	}
%>
<br><br>
<% if(ERMSG != null){ %>
予期せぬエラーが発生しました<br />

<%= ERMSG %>
<% }else{ %>
※エラーは発生しませんでした<br/>

<% } %>
<p id="back"><a href="./myag_main.jsp">メイン画面に戻る</a></p>
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
	<li class="right"></li>
	<li class="right"></li>
	<li class="right"></li>
	<li class="right"></li>
	<li class="right"></li>
	<li class="right"></li>
	<li class="right"></li>
	<li class="right"></li>
	<li class="right"></li>
	<li class="right"></li>
</ul>
</body>
</html>

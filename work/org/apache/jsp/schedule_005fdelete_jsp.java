package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import java.sql.*;

public final class schedule_005fdelete_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {

  private static final JspFactory _jspxFactory = JspFactory.getDefaultFactory();

  private static java.util.List _jspx_dependants;

  private javax.el.ExpressionFactory _el_expressionfactory;
  private org.apache.AnnotationProcessor _jsp_annotationprocessor;

  public Object getDependants() {
    return _jspx_dependants;
  }

  public void _jspInit() {
    _el_expressionfactory = _jspxFactory.getJspApplicationContext(getServletConfig().getServletContext()).getExpressionFactory();
    _jsp_annotationprocessor = (org.apache.AnnotationProcessor) getServletConfig().getServletContext().getAttribute(org.apache.AnnotationProcessor.class.getName());
  }

  public void _jspDestroy() {
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    PageContext pageContext = null;
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html; charset=UTF-8");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write("\r\n");
      out.write("\r\n");

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
		  SQL.append("delete from yotei_tbl where kaiin_id = '");
      SQL.append(session_id);
      SQL.append("' and day ='");
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

      out.write("\r\n");
      out.write("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\r\n");
      out.write("<html>\r\n");
      out.write("<head>\r\n");
      out.write("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\r\n");
      out.write("<title>予定削除</title>\r\n");
      out.write("<link rel=\"stylesheet\" type=\"text/css\" href=\"./css/info.css\">\r\n");
      out.write("</head>\r\n");
      out.write("<body>\r\n");

	if(del_count == 0){  //処理失敗

      out.write("\r\n");
      out.write("\t<h1>削除NG</h1><br>\r\n");
      out.write("\t  ");
      out.print( "削除処理が失敗しました" );
      out.write('\r');
      out.write('\n');

	}else{  //削除OK

      out.write("\r\n");
      out.write("\t<h1>削除OK</h1><br>\r\n");
      out.write("\t  ");
      out.print( del_count + "件　削除が完了しました" );
      out.write('\r');
      out.write('\n');

	}

      out.write("\r\n");
      out.write("<br><br>\r\n");
 if(ERMSG != null){ 
      out.write("\r\n");
      out.write("予期せぬエラーが発生しました<br />\r\n");
      out.write("\r\n");
      out.print( ERMSG );
      out.write('\r');
      out.write('\n');
 }else{ 
      out.write("\r\n");
      out.write("※エラーは発生しませんでした<br/>\r\n");
      out.write("\r\n");
 } 
      out.write("\r\n");
      out.write("<p id=\"back\"><a href=\"./main.jsp\">メイン画面に戻る</a></p>\r\n");
      out.write("<ul class=\"circles\">\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("\t<li class=\"right\"></li>\r\n");
      out.write("</ul>\r\n");
      out.write("</body>\r\n");
      out.write("</html>\r\n");
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          try { out.clearBuffer(); } catch (java.io.IOException e) {}
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}

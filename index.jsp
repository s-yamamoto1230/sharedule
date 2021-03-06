<%-- ログイン画面 --%>
<%
String logout = request.getParameter("logout");
if(logout != null){
  //セッション変数を削除
  session.removeAttribute("login_id");
  session.removeAttribute("login_name");
  session.removeAttribute("year");
  session.removeAttribute("month");
}
String session_id = (String)session.getAttribute("login_id");
if(session_id != null){
  response.sendRedirect("main.jsp");
}
String del = request.getParameter("del");
%>

<!DOCTYPE html>

<html>

  <head>

    <meta charset="utf-8">

    <title>sharedule</title>

    <link rel="stylesheet" type="text/css" href="./css/index.css">

  </head>

  <%
    if (del != null){
      if (del.equals("1")) {
  %>
    <body onLoad="loadDelete()">
  <%
      }
    }else{
  %>
    <body>
  <%
    }
  %>

      <form name="all_del" action="./all_del.jsp" method="post">
        <input id="all_del" type="button" name="all_del" value="テーブル削除" onclick="ShowAlldel();">
        <input type="hidden" name="all_del" value="all_del">
      </form>

    <div class='background'>
      <div class='wave -one'></div>
      <div class='wave -two'></div>
      <div class='wave -three'></div>
      <div class='wave -four'></div>
      <div class='wave -five'></div>
      <div class='concept'><br>予定を共有、シェアできる</div>
    </div>
      <h1 id="title">
        sharedule<br>
        sharedule<br>
        sharedule<br>
        sharedule<br>
        sharedule
      </h1>
      <h2 id="subtitle">
        share × schedule<br>
        share × schedule<br>
        share × schedule<br>
        share × schedule<br>
        share × schedule
      </h2>
       <form action="./logincheck.jsp" method="post">
        <table>
          <tr>
            <td>
              <p>ＩＤ</p>
            </td>
            <td>
              <input type="text" name="id" pattern="^[0-9a-z]+$" size="50" class="text" autofocus>
            </td>
          </tr>
          <tr>
            <td>
              <p>パスワード</p>
            </td>
            <td>
              <input type="password" name="pass" pattern="^[0-9a-z]+$" size="50" class="text">
            </td>

          <tr>
            <td class="info" colspan="2">
              <input type="submit" value="ログイン" id="button">
            </td>
          </form>
          </tr>
          <tr>
            <td class="info" colspan="2">
              <p id="new"><a href="./new_make.jsp">  新規登録の方はコチラ</a></p>
            </td>
          </tr>
            <tr>
              <td class="info" colspan="2">
                <p id="lost"><a href="pass_lost.jsp">  ID、パスワードをを忘れた方はコチラ</a></p>
              </td>
            </tr>


       </table>
      <script type="text/javascript" src="./js/main.js"></script>
  </body>

</html>

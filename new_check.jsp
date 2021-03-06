<%-- ユーザーID新規登録確認画面 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%
  String mailStr = request.getParameter("mail");
  String idStr = request.getParameter("id");
  String passStr = request.getParameter("password");
  String usernameStr = request.getParameter("username");
  String yearStr = request.getParameter("year");
  String monthStr = request.getParameter("month");
  String dayStr = request.getParameter("day");

  if (monthStr.equals("1") || monthStr.equals("2") || monthStr.equals("3") || monthStr.equals("4") || monthStr.equals("5") || monthStr.equals("6") || monthStr.equals("7") || monthStr.equals("8") || monthStr.equals("9")) {
    monthStr = "0"+monthStr;
  }
  if (dayStr.equals("1") || dayStr.equals("2") || dayStr.equals("3") || dayStr.equals("4") || dayStr.equals("5") || dayStr.equals("6") || dayStr.equals("7") || dayStr.equals("8") || dayStr.equals("9")) {
    dayStr = "0"+dayStr;
  }
  String bday = yearStr+monthStr+dayStr;
%>

<html>

  <head>

    <meta charset="utf-8">

    <title>新規登録(確認)</title>

    <link rel="stylesheet" type="text/css" href="./css/info.css">

  </head>

  <body>


    <h1>新規登録（確認）</h1>
    <h2>以下の内容で登録しますか？</h2>

    <table>
    <form action="./new_complete.jsp" method="post">

      <input type="hidden" name="mail" value="<%= mailStr %>">
      <input type="hidden" name="id" value="<%= idStr %>">
      <input type="hidden" name="pass" value="<%= passStr %>">
      <input type="hidden" name="username" value="<%= usernameStr %>">
      <input type="hidden" name="bday" value="<%= bday %>">

      <tr>
        <td>
          <p>メールアドレス</p>
        </td>
        <td class="check">
          <%= mailStr %>
        </td>
      </tr>
      <tr>
        <td>
          <p>ID</p>
        </td>
        <td class="check">
          <%= idStr %>
        </td>
      <tr>
        <td>
          <p>パスワード</p>
        </td>
        <td class="check">
          <%= "入力されたパスワード" %>
        </td>
      </tr>
      <tr>
        <td>
          <p>ユーザー名</p>
        </td>
        <td class="check">
          <%= usernameStr %>
        </td>
      <tr>
        <td>
          <p>生年月日</p>
        </td>
        <td class="check">
          <%= yearStr+"年"+monthStr+"月"+dayStr+"日" %>
        </td>

      <tr class="no-line">
        <td  id="button" class="no-line" colspan="2">
            <p>
              <input type="submit" value="登録">
              <button id="correction" type="button" href="javascript:void(0)" onclick="javascript:history.back()">修正</button>
            </p>
        </td>
      </form>
        <td class="no-line">
        </td>
      </tr>

        <tr class="no-line">
          <td class="no-line"></td>
          <td class="no-line"></td>
        </tr>
      </table>

  </body>

</html>

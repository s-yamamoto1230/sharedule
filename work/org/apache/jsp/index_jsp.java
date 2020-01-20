package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class index_jsp extends org.apache.jasper.runtime.HttpJspBase
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
      response.setContentType("text/html");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;


String logout = request.getParameter("logout");
if(logout != null){
  //ã»ãã·ã§ã³å¤æ°ãåé¤
  session.removeAttribute("login_id");
  session.removeAttribute("login_name");
  session.removeAttribute("year");
  session.removeAttribute("month");
}
String session_id = (String)session.getAttribute("login_id");
if(session_id != null){
  response.sendRedirect("main.jsp");
}

      out.write("\r\n");
      out.write("\r\n");
      out.write("<!DOCTYPE html>\r\n");
      out.write("\r\n");
      out.write("<html>\r\n");
      out.write("\r\n");
      out.write("  <head>\r\n");
      out.write("\r\n");
      out.write("    <meta charset=\"utf-8\">\r\n");
      out.write("\r\n");
      out.write("    <title>My Agenda</title>\r\n");
      out.write("\r\n");
      out.write("    <link rel=\"stylesheet\" type=\"text/css\" href=\"./css/index.css\">\r\n");
      out.write("\r\n");
      out.write("  </head>\r\n");
      out.write("\r\n");
      out.write("  <body>\r\n");
      out.write("\r\n");
      out.write("    <div class='background'>\r\n");
      out.write("      <div class='wave -one'></div>\r\n");
      out.write("      <div class='wave -two'></div>\r\n");
      out.write("      <div class='wave -three'></div>\r\n");
      out.write("      <div class='wave -four'></div>\r\n");
      out.write("      <div class='wave -five'></div>\r\n");
      out.write("      <div class='concept'>èªåã®äºå®ãç®¡çã<br>äºå®ãå±æãã·ã§ã¢ã§ãã</div>\r\n");
      out.write("    </div>\r\n");
      out.write("      <h1 id=\"title\">\r\n");
      out.write("        My Agenda<br>\r\n");
      out.write("        My Agenda<br>\r\n");
      out.write("        My Agenda<br>\r\n");
      out.write("        My Agenda<br>\r\n");
      out.write("        My Agenda\r\n");
      out.write("      </h1>\r\n");
      out.write("       <form action=\"./logincheck.jsp\" method=\"post\">\r\n");
      out.write("        <table>\r\n");
      out.write("          <tr>\r\n");
      out.write("            <td>\r\n");
      out.write("              <p>ï¼©ï¼¤</p>\r\n");
      out.write("            </td>\r\n");
      out.write("            <td>\r\n");
      out.write("              <input type=\"text\" name=\"id\" size=\"50\" class=\"text\" autofocus>\r\n");
      out.write("            </td>\r\n");
      out.write("          </tr>\r\n");
      out.write("          <tr>\r\n");
      out.write("            <td>\r\n");
      out.write("              <p>ãã¹ã¯ã¼ã</p>\r\n");
      out.write("            </td>\r\n");
      out.write("            <td>\r\n");
      out.write("              <input type=\"password\" name=\"pass\" size=\"50\" class=\"text\">\r\n");
      out.write("            </td>\r\n");
      out.write("\r\n");
      out.write("          <tr>\r\n");
      out.write("            <td class=\"info\" colspan=\"2\">\r\n");
      out.write("              <input type=\"submit\" value=\"ã­ã°ã¤ã³\" id=\"button\">\r\n");
      out.write("            </td>\r\n");
      out.write("          </form>\r\n");
      out.write("          </tr>\r\n");
      out.write("          <tr>\r\n");
      out.write("            <td class=\"info\" colspan=\"2\">\r\n");
      out.write("              <p id=\"new\"><a href=\"./new_make.jsp\">  æ°è¦ç»é²ã®æ¹ã¯ã³ãã©</a></p>\r\n");
      out.write("            </td>\r\n");
      out.write("          </tr>\r\n");
      out.write("            <tr>\r\n");
      out.write("              <td class=\"info\" colspan=\"2\">\r\n");
      out.write("                <p id=\"lost\"><a href=\"pass_lost.jsp\">  IDããã¹ã¯ã¼ãããå¿ããæ¹ã¯ã³ãã©</a></p>\r\n");
      out.write("              </td>\r\n");
      out.write("            </tr>\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("       </table>\r\n");
      out.write("\r\n");
      out.write("\r\n");
      out.write("  </body>\r\n");
      out.write("\r\n");
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

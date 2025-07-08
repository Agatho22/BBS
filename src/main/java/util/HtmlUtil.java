package util;

import java.net.URLEncoder;

public class HtmlUtil {

    public static String escapeHtml(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;")
                  .replace("<", "&lt;")
                  .replace(">", "&gt;")
                  .replace("\"", "&quot;")
                  .replace("'", "&#x27;");
    }

    public static String escapeHtmlAttribute(String str) {
        return escapeHtml(str).replace(" ", "&#x20;");
    }

    public static String escapeHtmlWithFormat(String str) {
        return escapeHtml(str).replace(" ", "&nbsp;").replace("\n", "<br>");
    }

    public static String escapeJavaScript(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("'", "\\'")
                  .replace("\r", "\\r")
                  .replace("\n", "\\n")
                  .replace("<", "\\x3C")
                  .replace(">", "\\x3E")
                  .replace("&", "\\x26");
    }

    public static String escapeUrl(String str) {
        if (str == null) return "";
        try {
            return URLEncoder.encode(str, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }
}

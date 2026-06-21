<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head><title>SV Test</title></head>
<body>
<h1>Test SV page</h1>
<p>selectedLop = ${selectedLop}</p>
<p>dssv size = ${dssv != null ? dssv.size() : 'null'}</p>
<p>svInLop = ${svInLop}</p>
<p>svNam = ${svNam}</p>
<p>svNu = ${svNu}</p>
<p>dslop size = ${dslop != null ? dslop.size() : 'null'}</p>
<c:if test="${not empty dssv}">
<table border="1">
<tr><th>MASV</th><th>HO</th><th>TEN</th><th>PHAI</th><th>MALOP</th><th>LUOT_DK</th></tr>
<c:forEach items="${dssv}" var="sv">
<tr>
<td>${sv.MASV}</td>
<td>${sv.HO}</td>
<td>${sv.TEN}</td>
<td>${sv.PHAI}</td>
<td>${sv.MALOP}</td>
<td>${sv.LUOT_DK}</td>
</tr>
</c:forEach>
</table>
</c:if>
</body>
</html>

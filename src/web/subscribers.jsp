<%@page import="org.jivesoftware.openfire.pubsub.NodeSubscription"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@ page import="java.net.URLEncoder" %>
<%@page import="org.jivesoftware.openfire.pubsub.Node"%>
<%@page import="com.lulu.openfire.plugin.PubSubManager" %>
<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager" />
<%
PubSubManager m = PubSubManager.getInstance();
String topicId = request.getParameter("topicId");
%>
<!DOCTYPE HTML>
<html>
<head>
    <title>My Plugin Page</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="subPageID" content="node-subscribers"/>
    <meta name="extraParams" content='<%= "topicId="+URLEncoder.encode(topicId, "UTF-8") %>'/>

<script type="text/javascript" src="js/jquery-1.8.2.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
	});
	
</script>
</head>
<body>
<div>Subscribers list</div>
<div class="jive-table">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<thead>
			<tr><th>Subscriber</th><th>Action</th></tr>
		</thead>
		<tbody>
	
<%
    int i = 0;
	for(NodeSubscription s : m.getTopticSubscribers(topicId)){ 
%>
	<tr class="jive-<%= (((i%2)==0) ? "even" : "odd") %>">
		<td><%= s.getJID()%></td>
		<td><input type="button" value="remove" /></td>
	</tr>
<%
        i++;
	}
%>
	</tbody>
	</table>
</div>
</body>
</html>

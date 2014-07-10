<%@page import="org.jivesoftware.openfire.pubsub.NodeSubscription"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@ page import="java.net.URLEncoder" %>
<%@page import="org.jivesoftware.openfire.pubsub.Node"%>
<%@page import="org.jivesoftware.openfire.pubsub.LeafNode"%>
<%@page import="org.jivesoftware.openfire.pubsub.PublishedItem"%>
<%@page import="com.lulu.openfire.plugin.PubSubManager" %>

<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager" />

<%
    PubSubManager m = PubSubManager.getInstance();
    String topicId = request.getParameter("topicId");
    Node topic = m.getTopic(topicId);
%>

<!DOCTYPE HTML>
<html>
<head>
    <title>Topic Info</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="subPageID" content="node-items"/>
    <meta name="extraParams" content='<%= "topicId="+URLEncoder.encode(topicId, "UTF-8") %>'/>
<style type="text/css">
	.clear{
		clear:both;
	}
</style>
<script type="text/javascript" src="js/jquery-1.8.2.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
	});
	
    function publishItem(topicId){
        content = $("#newTopicContent").val();
        $.post('doaction',{
            topicId: topicId,
            content: content,
            action: 'publishItem'
        }, function(result){
            if(result === 'true'){
                //alert('item added.');
                window.location.reload(false);
            }else{
                alert('failed.');
            }
        });
    }

    function deleteItem(topicId, itemId){
        $.post('doaction',{
            topicId: topicId,
            itemId: itemId,
            action: 'deleteItem'
        }, function(result){
            if(result === 'true'){
                //alert('item deleted.');
                window.location.reload(false);    
            }else{
                alert('failed.');
            }
        });
    }

</script>
</head>
<body>

<div>Item list</div>
<div id="item-list" class="jive-table">
    <table cellpadding="0" cellspacing="0" border="0" width="100%">
        <thead>
            <tr><th>ID</th><th>Content</th><th>CreationDate</th><th>Action</th></tr>
        </thead>
        <tbody>
<%
    List<PublishedItem> items = null;
    if (topic == null || topic.isCollectionNode()) {
        items = new ArrayList<PublishedItem>();
    } else {
        items = ((LeafNode)topic).getPublishedItems(50);
    }
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    int i = 0;
    for (PublishedItem item : items) {
        String content = item.getPayload() == null ? "" : item.getPayload().getText();
%>
    <tr class="jive-<%= (((i%2)==0) ? "even" : "odd") %>">
        <td><%= item.getID()%></td>
        <td><%= content %></td>
        <td><%= sdf.format(item.getCreationDate()) %></td>
        <td><input type="button" value="delete" onclick='deleteItem("<%= topicId %>", "<%= item.getID()%>")' /></td>
    </tr>
<%
        i++;
    }
%>
            <tr class="jive-<%= (((i%2)==0) ? "even" : "odd") %>">
              <td></td><td><input type="text" id="newTopicContent"></td>
              <td></td>
              <td><input type="button" value="publish" onclick='publishItem("<%= topicId %>")' /></td>
            </tr>
        </tbody>
    </table>
</div>


</body>
</html>

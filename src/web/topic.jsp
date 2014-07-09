<%@page import="org.jivesoftware.openfire.pubsub.NodeSubscription"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.jivesoftware.openfire.pubsub.Node"%>
<%@page import="org.jivesoftware.openfire.pubsub.LeafNode"%>
<%@page import="org.jivesoftware.openfire.pubsub.PublishedItem"%>
<%@page import="com.lulu.openfire.plugin.PubSubManager" %>

<!DOCTYPE HTML>
<html>
<head>
<title>My Plugin Page</title>

<style type="text/css">
	.clear{
		clear:both;
	}
	#subscribe-list{
		width: 100%
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
<%
    PubSubManager m = PubSubManager.getInstance();
    String topicId = request.getParameter("topicId");
    Node topic = m.getTopic(topicId);
%>

<div>Item list</div>
<div id="item-list">
    <table border="1">
        <thead>
            <tr><td>ID</td><td>Content</td><td>CreationDate</td><td>Action</td></tr>
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
    for (PublishedItem item : items) {
        String content = item.getPayload() == null ? "" : item.getPayload().getText();
%>
    <tr>
        <td><%= item.getID()%></td>
        <td><%= content %></td>
        <td><%= sdf.format(item.getCreationDate()) %></td>
        <td><input type="button" value="delete" onclick='deleteItem("<%= topicId %>", "<%= item.getID()%>")' /></td>
    </tr>
<%
    }
%>
            <tr>
              <td></td><td><input type="text" id="newTopicContent"></td>
              <td><input type="button" value="publish" onclick='publishItem("<%= topicId %>")' /></td>
            </tr>
        </tbody>
    </table>
</div>

<div>Subscriber list</div>
<div id="subscribe-list">
	<table border="1">
		<thead>
			<tr><td>Subscriber</td><td>Action</td></tr>
		</thead>
		<tbody>
	
<%
	//PubSubManager m = PubSubManager.getInstance();
	//String topicId = request.getParameter("topicId");
	for(NodeSubscription s:m.getTopticSubscribers(topicId)){ 
%>
			<tr>
				<td><%= s.getJID()%></td>
				<td><input type="button" value="remove" /></td>
			</tr>
<%
	}
%>
	</tbody>
	</table>
</div>
</body>
</html>

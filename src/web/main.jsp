<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="org.jivesoftware.openfire.pubsub.Node"%>
<%@page import="com.lulu.openfire.plugin.PubSubManager" %>

<!DOCTYPE HTML>
<html>
<head>
<title>Topic List</title>

    <meta name="pageID" content="nodelist" />

<script type="text/javascript" src="js/jquery-1.8.2.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
	});
	
    function addTopic(){
        topicId = $("#newTopicId").val();
        $.post('doaction',{
            topicId: topicId,
            action: 'addTopic'
        }, function(result){
            if(result === 'true'){
                alert('topic added.');    
            }else{
                alert('failed.');
            }
            
        });
    }

	function removeTopic(topicId){
		$.post('doaction',{
			topicId: topicId,
			action: 'removeTopic'
		}, function(result){
			if(result === 'true'){
				alert('topic removed.');	
			}else{
				alert('failed.');
			}
			
		});
	}
	
	function showSubscribers(topicId){
		$.get('doaction',{
			topicId: topicId,
			action: 'getSubscribers'
		}, function(result){
			$('#subscriber-body').empty();
			for(var i = 0; i < result.length; i++){
				$('#subscriber-body').append(createSubscriberNode(topicId, result[i]));	
			}
			// Add subscriber.
			$('#subscriber-body').append(createAddSubscriberNode(topicId));  
		},'json');
	}
	
	function createSubscriberNode(topicId, nodesub){
		var $btn = $('<input type="button" value="remove"/>'),
			$tr = $('<tr></tr>'),
			$id = $('<td>' + nodesub.jid + '</td>'),
			$action = $('<td></td>');
		
		$btn.click(function(){
			$.get('doaction',{
				topicId: topicId,
				action: 'removeSubscriber',
				jid: nodesub.jid
			}, function(result){
				showSubscribers(topicId);							
			});
		});
		
		$action.append($btn);
		$tr.append($id).append($action);
		return $tr;
	}
    function createAddSubscriberNode(topicId){
        var $btn = $('<input type="button" value="add"/>'),
            $tr = $('<tr></tr>'),
            //$id = $('<td>' + nodesub.jid + '</td>'),
            $id = $('<td><input type="text" id="newSubscriberId"></td>'),
            $action = $('<td></td>');
        
        $btn.click(function(){
            id = $("#newSubscriberId").val();
            $.get('doaction',{
                topicId: topicId,
                action: 'addSubscriber',
                jid: id
            }, function(result){
                showSubscribers(topicId);                           
            });
        });
        
        $action.append($btn);
        $tr.append($id).append($action);
        return $tr;
    }
</script>
</head>
<body>
<%
    PubSubManager m = PubSubManager.getInstance();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    List<Node> topics = m.getToptics();
%>
<p>Total: <%= topics.size() %></p>
<div id="topic-list" class="jive-table">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<thead>
			<tr><th>NodeId</th><th>Creator</th><th>CreationDate</th><th>Subscriptions</th><th>PublisherModel</th><th>Action</th></tr>
		</thead>
		<tbody>
	
<%
    int i = 0;
	for(Node n : topics){
		if(n.getNodeID().trim().equals("")){
			continue;
		}
%>
	<tr class="jive-<%= (((i%2)==0) ? "even" : "odd") %>">
        <td><a href="topic.jsp?topicId=<%= n.getNodeID()%>" ><%= n.getNodeID()%></a></td>
		<td><%= n.getCreator()%></td>
		<td><%= sdf.format(n.getCreationDate()) %></td>
		<td><%= n.getAllSubscriptions().size() %></td>
		<td><%= n.getPublisherModel().getName() %></td>
		<td><input type="button" value="remove" onclick='removeTopic("<%= n.getNodeID()%>")'/></td>
	</tr>
<%
        i++;
	}
%>
	</tbody>
	</table>
</div>
<!-- div>Subscribers list</div>
<div id="subscriber-list">
	<table border="1">
		<thead>
			<tr>
				<td>Subscriber</td>
				<td>Action</td>
			</tr>
		</thead>
		<tbody id="subscriber-body">
		</tbody>
	</table>
</div -->
</body>
</html>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="org.jivesoftware.openfire.pubsub.Node"%>
<%@page import="com.lulu.openfire.plugin.PubSubManager" %>

<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager"  />
<% webManager.init(request, response, session, application, out ); %>

<!DOCTYPE HTML>
<html>
<head>
<title>Create New Topic</title>

    <meta name="pageID" content="node-create" />

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
</script>
</head>
<body>
    <div class="jive-contentBoxHeader">Add Topic
    </div>
    <div class="jive-contentBox">
      <form>
        <p nowrap>New Topic 
          <input type="text" size="80" id="newTopicId" />
          <input type="button" value="submit" onclick='addTopic()' />
        </p>
      </form>
      <p>Create a new topic here.</p>
    </div>
</body>
</html>

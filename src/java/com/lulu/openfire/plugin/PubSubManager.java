package com.lulu.openfire.plugin;

import java.util.ArrayList;
import java.util.List;

import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.QName;
import org.jivesoftware.openfire.XMPPServer;
import org.jivesoftware.openfire.pubsub.CollectionNode;
import org.jivesoftware.openfire.pubsub.DefaultNodeConfiguration;
import org.jivesoftware.openfire.pubsub.LeafNode;
import org.jivesoftware.openfire.pubsub.Node;
import org.jivesoftware.openfire.pubsub.NodeSubscription;
import org.jivesoftware.openfire.pubsub.PubSubModule;
import org.jivesoftware.openfire.pubsub.PubSubPersistenceManager;
import org.jivesoftware.openfire.pubsub.PublishedItem;
import org.jivesoftware.openfire.user.UserManager;
import org.jivesoftware.util.WebManager;
import org.xmpp.packet.JID;

// TODO: We should get the correct user name instead of the hard-coded "admin".

public class PubSubManager {
	private PubSubModule pubSubModule = null;
	private static PubSubManager instance = null;

	private PubSubManager(){
		pubSubModule = XMPPServer.getInstance().getPubSubModule();
		// Do some plugin initialization here.
		// Or we can also set the options in Admin console.
		DefaultNodeConfiguration leafNodeConfig = pubSubModule.getDefaultNodeConfiguration(true);
		boolean shouldUpdate = false;
//System.out.println("init: " + leafNodeConfig.isPersistPublishedItems());
		if (!leafNodeConfig.isPersistPublishedItems()) {
		    leafNodeConfig.setPersistPublishedItems(true);
		    shouldUpdate = true;
		}
        if (!leafNodeConfig.isDeliverPayloads()) {
            leafNodeConfig.setDeliverPayloads(true);
            shouldUpdate = true;
        }
		if (shouldUpdate) {
		    System.out.println("Update DefaultNodeConfiguration.");
		    PubSubPersistenceManager.updateDefaultConfiguration(pubSubModule, leafNodeConfig);
		}
	}

	public static synchronized PubSubManager getInstance(){
		if(instance == null){			
			instance = new PubSubManager();
		}
		return instance;
	}

	public List<Node> getToptics(){
		List<Node> list = new ArrayList<Node>();
		list.addAll(pubSubModule.getNodes());
		return list;
	}

	public List<NodeSubscription> getTopticSubscribers(String topicId){
		List<NodeSubscription> list = new ArrayList<NodeSubscription>();
		Node node = pubSubModule.getNode(topicId);
		list.addAll(node.getAllSubscriptions());
		return list;
	}

	public boolean removeTopic(String topicId){
		Node node = pubSubModule.getNode(topicId);
		return node.delete();
	}

	public Node getTopic(String topicId){
		Node node = pubSubModule.getNode(topicId);
		return node;
	}

    public boolean addTopic(String topicId) {
        Node node = pubSubModule.getNode(topicId);
        if (node != null) {
            return false;
        }
        JID creator = XMPPServer.getInstance().createJID("admin", null);
        LeafNode newTopic = new LeafNode(pubSubModule, null, topicId, creator);
        // Create CollectionNode if we have more depth.
        //CollectionNode newNode = new CollectionNode(pubSubModule, null, topicId, creator);
        newTopic.addOwner(creator);
        newTopic.saveToDB();
        return true;
    }

    // TODO: add sys admin.
    public void setSysAdmins(JID bareJID) {
        if (!UserManager.getInstance().isRegisteredUser(bareJID.toBareJID())) {
            return;
        }
        pubSubModule.addSysadmin(bareJID.toBareJID());
    }

    // Delete a published item.
    public boolean deleteItem(String topicId, String itemId) {
        Node node = pubSubModule.getNode(topicId);
        if (node == null) {
            return false;
        }
        PublishedItem item = node.getPublishedItem(itemId);
        if (item == null || !item.canDelete(node.getCreator())) {
            return false;
        }
        if (node.isCollectionNode()) {
            // Node is a collection node.
            return false;
        }
        LeafNode leafNode = (LeafNode) node;
        List<PublishedItem> items = new ArrayList<PublishedItem>();
        items.add(item);
        leafNode.deleteItems(items);
        return true;
    }

    // Publish a new item.
    public boolean publishItem(String topicId, String data) {
        Node node = pubSubModule.getNode(topicId);
        if (node == null) {
            return false;
        }
        // Check for privilege.
        JID owner = XMPPServer.getInstance().createJID("admin", null);
        if (!node.getPublisherModel().canPublish(node, owner) && 
                !pubSubModule.isServiceAdmin(owner)) {
            // Entity does not have sufficient privileges to publish to node
            return false;
        }
        if (node.isCollectionNode()) {
            // Node is a collection node.
            return false;
        }
        LeafNode leafNode = (LeafNode) node;

        // TODO: Check that an item was included if node persist items or includes payload
        // Check that no item was included if node doesn't persist items and doesn't includes payload

        String[] payloads = new String[1];
        payloads[0] = data;
        leafNode.publishItems(owner, createPublishItemElements(payloads));
        return true;
    }

    static List<Element> createPublishItemElements(String[] payloads) {
        Document document = DocumentHelper.createDocument();
        Element pubsubEle = document.addElement(QName.get("pubsub", "http://jabber.org/protocol/pubsub"));
        Element publishEle = pubsubEle.addElement("publish");

        List<Element> items = new ArrayList<Element>();
        for (String payload : payloads) {
            Element publishItemEle = publishEle.addElement("item");
            // Let the pubsub service decide an unique ID.
            //publishItemEle.addAttribute("id", generateUniquePublishItemID());
            publishItemEle.addElement("message").addText(payload);
            items.add(publishItemEle);
        }
        return items;
    }

    static String generateUniquePublishItemID() {
        // TBD if needed.
        return "";
    }

    static String generateSubscriptionID(String nodeID, String uid) {
        // So that one user will only have one subscription. (TO make things simple.)
        return nodeID + "-" + uid;
    }
}

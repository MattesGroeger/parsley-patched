package org.spicefactory.parsley.binding.impl {
import org.spicefactory.lib.util.ArrayUtil;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.binding.BindingManager;
import org.spicefactory.parsley.binding.Publisher;
import org.spicefactory.parsley.binding.Subscriber;

import flash.utils.Dictionary;

/**
 * Default implementation of the BindingManager interface.
 * 
 * @author Jens Halm
 */
public class DefaultBindingManager implements BindingManager {


	private var publishers:Array = new Array();
	private var subscribers:Dictionary = new Dictionary();


	/**
	 * @inheritDoc
	 */
	public function addPublisher (publisher:Publisher) : void {
		doAddPublisher(publisher, true);
	}
	
	private function doAddPublisher (publisher:Publisher, checkSubsriber:Boolean) : void {
		publisher.init();
		publishers.push(publisher);
		for each (var collection:SubscriberCollection in subscribers) {
			if (collection.isMatchingType(publisher)) {
				collection.addPublisher(publisher);
			}
		}
		if (checkSubsriber && publisher is Subscriber) doAddSubscriber(publisher as Subscriber, false);
	}


	/**
	 * @inheritDoc
	 */
	public function removePublisher (publisher:Publisher) : void {
		doRemovePublisher(publisher, true);
	}
	
	private function doRemovePublisher (publisher:Publisher, checkSubsriber:Boolean) : void {
		publisher.dispose();
		ArrayUtil.remove(publishers, publisher);
		for each (var collection:SubscriberCollection in subscribers) {
			if (collection.isMatchingType(publisher)) {
				collection.removePublisher(publisher);
			}
		}
		if (checkSubsriber && publisher is Subscriber) doRemoveSubscriber(publisher as Subscriber, false);
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function addSubscriber (subscriber:Subscriber) : void {
		doAddSubscriber(subscriber, true);
	}
	
	private function doAddSubscriber (subscriber:Subscriber, checkPublisher:Boolean) : void {
		var collection:SubscriberCollection = getCollection(subscriber.type);
		if (collection.empty) {
			for each (var publisher:Publisher in publishers) {
				if (collection.isMatchingType(publisher)) {
					collection.addPublisher(publisher);
				}
			}
		}
		collection.addSubscriber(subscriber);
		if (checkPublisher && subscriber is Publisher) doAddPublisher(subscriber as Publisher, false);
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeSubscriber (subscriber:Subscriber) : void {
		doRemoveSubscriber(subscriber, true);
	}
	
	private function doRemoveSubscriber (subscriber:Subscriber, checkPublisher:Boolean) : void {
		var collection:SubscriberCollection = getCollection(subscriber.type, false);
		if (collection != null) {
			collection.removeSubscriber(subscriber);
			if (collection.empty) {
				delete subscribers[subscriber.type.getClass()];
			}
		}
		if (checkPublisher && subscriber is Publisher) doRemovePublisher(subscriber as Publisher, false);
	}
	
	
	private function getCollection (type:ClassInfo, create:Boolean = true) : SubscriberCollection {
		var collection:SubscriberCollection = subscribers[type.getClass()] as SubscriberCollection;
		if (collection == null && create) {
			collection = new SubscriberCollection(type);
			subscribers[type.getClass()] = collection;
		}
		return collection;
	}
	
	
}
}

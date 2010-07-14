package org.spicefactory.parsley.binding {

/**
 * The central manager of the decoupled binding facility.
 * Each scope will get its own instance.
 * 
 * <p>The publishers and subscribers added to this manager may
 * optionally implement both the Publisher and Subscriber interface.
 * You only have to invoke <code>addSubscriber</code> or <code>addPublisher</code>
 * once in this case, the other interface will automatically be detected.</p>
 * 
 * @author Jens Halm
 */
public interface BindingManager {
	
	
	/**
	 * Adds a publisher to this manager.
	 * 
	 * @param publisher the publisher to add 
	 */
	function addPublisher (publisher:Publisher) : void;
	
	/**
	 * Adds a subscriber to this manager.
	 * 
	 * @param subscriber the subscriber to add 
	 */
	function addSubscriber (subscriber:Subscriber) : void;
	
	/**
	 * Removes a publisher from this manager.
	 * 
	 * @param publisher the publisher to remove 
	 */
	function removePublisher (publisher:Publisher) : void;
	
	/**
	 * Removes a subscriber from this manager.
	 * 
	 * @param subscriber the subscriber to remove 
	 */
	function removeSubscriber (subscriber:Subscriber) : void;
	
	
}
}

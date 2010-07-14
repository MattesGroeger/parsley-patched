package org.spicefactory.parsley.binding {
import org.spicefactory.lib.reflect.ClassInfo;

/**
 * Subscribes to the values of one or more matching publishers.
 * 
 * @author Jens Halm
 */
public interface Subscriber {
	
	
	/**
	 * The type of the published value.
	 * May be an interface or supertype of the actual published value.
	 */
	function get type () : ClassInfo;
	
	/**
	 * The optional id of the published value.
	 * If omitted subscribers and publishers will solely be matched by type.
	 */
	function get id () : String;
	
	/**
	 * Notifies this suscriber that the published value has changed.
	 * 
	 * @param newValue the new value of the matching publisher
	 */
	function update (newValue:*) : void;
	
	
}
}

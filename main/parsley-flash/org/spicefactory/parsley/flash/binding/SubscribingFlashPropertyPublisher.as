package org.spicefactory.parsley.flash.binding {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.Subscriber;
import org.spicefactory.parsley.binding.impl.PropertySubscriber;
import org.spicefactory.parsley.core.context.Context;

/**
 * A publisher that observes the value of a single property and uses its value
 * as the published value and subscribes to the values of other matching publishers at the same time. 
 * 
 * <p>This implementation does not rely on the Flex Binding facility so that it can be used in Flash applications.</p>
 * 
 * @author Jens Halm
 */
public class SubscribingFlashPropertyPublisher extends FlashPropertyPublisher implements Subscriber {


	private var subscriber:Subscriber;

	/**
	 * Creates a new instance.
	 * 
	 * @param target the instance that holds the property to observe
	 * @param property the target property that holds the published value
	 * @param changeEvent the event type that signals that the property value has changed
	 * @param type the type of the published value
	 * @param id the id the value is published with
	 * @param context the corresponding Context in case the published object should be managed
	 */
	function SubscribingFlashPropertyPublisher (target:Object, property:Property, changeEvent:String, 
			type:ClassInfo = null, id:String = null, context:Context = null) {
		super(target, property, changeEvent, type, id, context);
		this.subscriber = new PropertySubscriber(target, property, type, id);
	}

	
	/**
	 * @inheritDoc
	 */	
	public function update (newValue:*) : void {
		enabled = false;
		try {
			subscriber.update(newValue);
		}
		finally {
			enabled = true;
		}
	}
	

}
}

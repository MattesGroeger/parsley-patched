package org.spicefactory.parsley.binding.impl {
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.Subscriber;
import org.spicefactory.parsley.core.context.Context;

/**
 * A publisher that observes the value of a single property and uses its value
 * as the published value and subscribes to the values of other matching publishers at the same time. 
 * 
 * <p>This implementation relies on the Flex Binding facility.
 * For Flash applications you can use the <code>FlashPropertyPublisher</code> implementation.</p>
 * 
 * @author Jens Halm
 */
public class SubscribingPropertyPublisher extends PropertyPublisher implements Subscriber {


	private var subscriber:Subscriber;

	
	/**
	 * Creates a new instance.
	 * 
	 * @param target the instance that holds the property to observe
	 * @param property the target property that holds the published value
	 * @param type the type of the published value
	 * @param id the id the value is published with
	 * @param context the corresponding Context in case the published object should be managed
	 */
	function SubscribingPropertyPublisher (target:Object, property:Property, 
			type:ClassInfo = null, id:String = null, context:Context = null) {
		super(target, property, type, id, context);
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

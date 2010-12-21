package org.spicefactory.parsley.flash.binding {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.BindingManager;
import org.spicefactory.parsley.binding.Publisher;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.lifecycle.ManagedObject;
import org.spicefactory.parsley.core.registry.ObjectProcessor;
import org.spicefactory.parsley.core.registry.ObjectProcessorFactory;
import org.spicefactory.parsley.processor.util.ObjectProcessorFactories;

/**
 * Processes a single property holding a a value that
 * should be published to matching subscribers.
 * It makes sure that the publisher is registered with the corresponding
 * BindingManager of the target scope during the lifetime of a managed object.
 * 
 * This implementation does not rely on the Flex Binding facility so that it can be used in Flash applications.
 * 
 * @author Jens Halm
 */
public class FlashPublisherProcessor implements ObjectProcessor {


	private var target:ManagedObject;
	private var publisher:Publisher;
	private var manager:BindingManager;


	/**
	 * Creates a new instance.
	 * 
	 * @param target the managed target object
	 * @param property the target property that holds the published value
	 * @param changeEvent the event type that signals that the property value has changed
	 * @param scope the scope the property value is published to
	 * @param id the id the value is published with
	 * @param managed whether the published object should be added to the Context while being published
	 * @param subscribe whether the publisher should also act as a subscriber
	 */
	function FlashPublisherProcessor (target:ManagedObject, property:Property, changeEvent:String, scope:String, id:String = null,
			managed:Boolean = false, subscribe:Boolean = false) {
		this.target = target;
		var context:Context = (managed) ? target.context : null;
		this.publisher = (subscribe)
				? new SubscribingFlashPropertyPublisher(target.instance, property, changeEvent, property.type, id, context)
				: new FlashPropertyPublisher(target.instance, property, changeEvent, property.type, id, context);
		this.manager = target.context.scopeManager.getScope(scope)
				.extensions.forType(BindingManager) as BindingManager;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function preInit () : void {
		manager.addPublisher(publisher);
	}
	
	/**
	 * @inheritDoc
	 */
	public function postDestroy () : void {
		manager.removePublisher(publisher);
	}
	
	
	/**
	 * Creates a new processor factory.
	 * 
	 * @param property the target property that holds the published value
	 * @param changeEvent the event that signals that the property value has changed
	 * @param scope the scope the property value is published to
	 * @param id the id the value is published with
	 * @param managed whether the published object should be added to the Context while being published
	 * @param subscribe whether the publisher should also act as a subscriber
	 * @return a new processor factory 
	 */
	public static function newFactory (property:Property, changeEvent:String, scope:String, id:String = null, 
			managed:Boolean = false, subscribe:Boolean = false) : ObjectProcessorFactory {
		return ObjectProcessorFactories.newFactory(FlashPublisherProcessor, [property, changeEvent, scope, id, managed, subscribe]);
	}
	
	/**
	 * @private
	 */
	public function toString () : String {
		return (publisher as Object).toString();
	}
	
	
}
}

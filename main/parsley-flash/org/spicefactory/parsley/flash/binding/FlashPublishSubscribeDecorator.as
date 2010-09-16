package org.spicefactory.parsley.flash.binding {
import org.spicefactory.lib.errors.IllegalStateError;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.processor.PersistentPublisherProcessor;
import org.spicefactory.parsley.config.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.scope.Scope;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.tag.util.ReflectionUtil;

import flash.events.Event;

[Metadata(name="PublishSubscribe", types="property")]
[XmlMapping(elementName="publish-subscribe")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on properties that hold a value that
 * should be published to matching subscribers while at the same time acting as a subscriber
 * for matching publishers.
 * 
 * This implementation does not rely on the Flex Binding facility so that it can be used in Flash applications.
 * 
 * @author Jens Halm
 */
public class FlashPublishSubscribeDecorator implements ObjectDefinitionDecorator {


	/**
	 * The scope the property value is published to.
	 */
	public var scope:String = ScopeName.GLOBAL;

	/**
	 * The id the property value is published with.
	 */
	public var objectId:String;

	[Target]
	/**
	 * The property that holds the value to publish and subscribe to.
	 */
	public var property:String;
	
	/**
	 * The event that signals that the property value has changed.
	 */
	public var changeEvent:String = Event.CHANGE; 

	/**
	 * Indicates whether the value published by this property should be 
	 * added to the Context (turned into a managed object) while being
	 * published. 
	 */
    public var managed:Boolean;
    
    /**
     * Indicates whether the value published by this property should be persisted.
     * The actual persistence mechanism is pluggable, the default implementation
     * persists to a local SharedObject.
     */
    public var persistent:Boolean;
    
	
	/**
	 * @inheritDoc
	 */
	public function decorate (builder:ObjectDefinitionBuilder) : void {
		if (!changeEvent) {
			throw new IllegalStateError("changeEvent must be specified");
		}
		var p:Property = ReflectionUtil.getProperty(property, builder.typeInfo, true, true);
		if (persistent) {
			var s:Scope = builder.config.context.scopeManager.getScope(scope);
			builder.lifecycle().processorFactory(PersistentPublisherProcessor.newFactory(p, s, objectId));
		}
		
		builder.lifecycle().processorFactory(FlashPublisherProcessor.newFactory(p, changeEvent, scope, objectId, managed, true));
	}
	

}
}

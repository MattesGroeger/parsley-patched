package org.spicefactory.parsley.binding.decorator {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.processor.SubscriberProcessor;
import org.spicefactory.parsley.config.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.tag.util.ReflectionUtil;

[Metadata(name="Subscribe", types="property")]
[XmlMapping(elementName="subscribe")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on properties that
 * should be bound to the value of a matching publisher.
 * 
 * @author Jens Halm
 */
public class SubscribeDecorator implements ObjectDefinitionDecorator {


	/**
	 * The scope the binding listens to.
	 */
	public var scope:String = ScopeName.GLOBAL;

	/**
	 * The id the source is published with.
	 */
	public var objectId:String;

	[Target]
	/**
	 * The property that binds to the subscribed value.
	 */
	public var property:String;
	
	
	/**
	 * @inheritDoc
	 */
	public function decorate (builder:ObjectDefinitionBuilder) : void {
		var p:Property = ReflectionUtil.getProperty(property, builder.typeInfo, false, true);
		builder.lifecycle().processorFactory(SubscriberProcessor.newFactory(p, scope, objectId));
	}
	

}
}

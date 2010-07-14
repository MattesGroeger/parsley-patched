package org.spicefactory.parsley.binding.decorator {
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.processor.PublisherProcessor;
import org.spicefactory.parsley.config.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.tag.util.ReflectionUtil;

[Metadata(name="PublishSubscribe", types="property")]
[XmlMapping(elementName="publish-subscribe")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on properties that hold a value that
 * should be published to matching subscribers while at the same time acting as a subscriber
 * for matching publishers.
 * 
 * @author Jens Halm
 */
public class PublishSubscribeDecorator implements ObjectDefinitionDecorator {


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
	 * Indicates whether the value published by this property should be 
	 * added to the Context (turned into a managed object) while being
	 * published. 
	 */
    public var managed:Boolean;
	
	/**
	 * @inheritDoc
	 */
	public function decorate (builder:ObjectDefinitionBuilder) : void {
		var p:Property = ReflectionUtil.getProperty(property, builder.typeInfo, true, true);
		builder.lifecycle().processorFactory(PublisherProcessor.newFactory(p, scope, objectId, managed, true));
	}
	

}
}

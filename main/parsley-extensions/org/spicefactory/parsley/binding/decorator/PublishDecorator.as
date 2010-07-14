package org.spicefactory.parsley.binding.decorator {
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.binding.processor.PublisherProcessor;
import org.spicefactory.parsley.config.ObjectDefinitionDecorator;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.tag.util.ReflectionUtil;

[Metadata(name="Publish", types="property")]
[XmlMapping(elementName="publish")]
/**
 * Represents a Metadata, MXML or XML tag that can be used on properties that hold a value that
 * should be published to matching subscribers.
 * 
 * @author Jens Halm
 */
public class PublishDecorator implements ObjectDefinitionDecorator {


	/**
	 * The scope the property value is published to.
	 */
	public var scope:String = ScopeName.GLOBAL;

	/**
	 * The optional id the property value is published with.
	 */
	public var objectId:String;

	[Target]
	/**
	 * The property that holds the value to publish.
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
		var p:Property = ReflectionUtil.getProperty(property, builder.typeInfo, true, false);
		builder.lifecycle().processorFactory(PublisherProcessor.newFactory(p, scope, objectId, managed));
	}
	

}
}

package org.spicefactory.parsley.xml.impl {
import org.spicefactory.lib.expr.ExpressionContext;
import org.spicefactory.lib.xml.XmlObjectMapper;
import org.spicefactory.lib.xml.XmlProcessorContext;
import org.spicefactory.parsley.core.ContextError;
import org.spicefactory.parsley.core.impl.MetadataObjectDefinitionBuilder;
import org.spicefactory.parsley.factory.ObjectDefinitionFactory;
import org.spicefactory.parsley.factory.ObjectDefinitionRegistry;
import org.spicefactory.parsley.factory.RootObjectDefinition;

/**
 * @author Jens Halm
 */
public class XmlObjectDefinitionBuilder {
	
	
	private var builder:MetadataObjectDefinitionBuilder = new MetadataObjectDefinitionBuilder();
	
	private var mapper:XmlObjectMapper; // TODO - create mapper

	
	public function build (containers:Array, registry:ObjectDefinitionRegistry, expressionContext:ExpressionContext = null):void {
		var context:XmlProcessorContext = new XmlProcessorContext(expressionContext, registry.domain);
		for each (var containerXML:XML in containers) {
			var container:ObjectDefinitionFactoryContainer 
					= mapper.mapToObject(containerXML, context) as ObjectDefinitionFactoryContainer;
			if (container != null) {
				for each (var factory:ObjectDefinitionFactory in container.factories) {
					try {
						var definition:RootObjectDefinition = factory.createRootDefinition(registry);
						builder.processMetadata(registry, definition);
						factory.applyDecorators(definition, registry);
						registry.registerDefinition(definition);
					} 
					catch (error:Error) {
						context.addError(error);
					}
				}
			}	
		}
		if (context.hasErrors()) {
			var msg:String = "XML Context configuration contains one or more errors: ";
			for each (var e:Error in context.errors) msg += "\n" + e.message; 
			throw new ContextError(msg);
		}
	}
	
	
}
}

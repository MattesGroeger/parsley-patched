package org.spicefactory.parsley.namespaces.logging {
import org.spicefactory.lib.logging.LogLevel;
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.LogFactory;
import org.spicefactory.lib.logging.impl.DefaultLogFactory;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Converter;
import org.spicefactory.lib.reflect.converter.BooleanConverter;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.Command;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.converter.LogLevelConverter;
import org.spicefactory.parsley.context.factory.FactoryMetadata;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Processes the custom <code>log-factory</code> tag and all of its child nodes.
 * 
 * @author Jens Halm
 */
public class LogFactoryConfig extends AbstractElementConfig implements ObjectFactoryConfig {



	private var processors:Array = new Array();

	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			ep.addAttribute("id", StringConverter.INSTANCE, true);
			var c : Converter = new ClassInfoConverter(ClassInfo.forClass(LogFactory), domain);
			ep.addAttribute("type", c, false, ClassInfo.forClass(DefaultLogFactory));
			ep.addAttribute("context", BooleanConverter.INSTANCE, false, true);
			ep.addAttribute("root-level", LogLevelConverter.INSTANCE, false, LogLevel.TRACE);
			ep.permitCustomNamespaces(ObjectProcessorConfig);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function parseRootObject (node : XML, context : ApplicationContext) : FactoryMetadata {
		parseFactory(node, context, true);
		return new FactoryMetadata(getAttributeValue("id"), true, false);
	}
	
	/**
	 * @inheritDoc
	 */
	public function parseNestedObject (node : XML, context : ApplicationContext) : void {
		parseFactory(node, context, false);
	}
	
	private function parseFactory (node:XML, context:ApplicationContext, root:Boolean) : void {
		parse(node, context);
		var createInContext:Boolean = getAttributeValue("context");
		if (createInContext) {
			if (!root) {
				throw new ConfigurationError("Only LogFactories as root object configurations" +
					" can be used as LogContext factory"); 			
			}
			context.addInitCommand(new Command(context.getObject, [getAttributeValue("id")]));
		}
	}
	
	/**
	 * Adds configuration for an Appender or a LogLevel.
	 * 
	 * @param config the configuration to add to this LogFactory
	 */
	public function addChildConfig (config:ObjectProcessorConfig) : void {
		processors.push(config);
	}
	
	/**
	 * @inheritDoc
	 */
	public function createObject () : Object {
		var factoryType:ClassInfo = getAttributeValue("type");
		var factory:LogFactory = LogFactory(factoryType.newInstance([]));
		factory.setRootLogLevel(getAttributeValue("rootLevel"));
		for each (var processor:ObjectProcessorConfig in processors) {
			processor.process(factory, null, null); // second and third param not needed in child tags
		}
		factory.refresh();
		var createInContext:Boolean = getAttributeValue("context");
		if (createInContext) {
			LogContext.factory = factory;
		}
		return factory;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get type () : ClassInfo {
		return ClassInfo.forClass(LogFactory);
	}
	
	
}

}

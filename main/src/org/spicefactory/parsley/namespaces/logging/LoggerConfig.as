package org.spicefactory.parsley.namespaces.logging {
import org.spicefactory.lib.logging.LogFactory;
import org.spicefactory.lib.logging.LogLevel;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.converter.LogLevelConverter;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the custom <code>logger</code> tag.
 * 
 * @author Jens Halm
 */
public class LoggerConfig extends AbstractElementConfig implements ObjectProcessorConfig {
	
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("name", StringConverter.INSTANCE, true);
			ep.addAttribute("level", LogLevelConverter.INSTANCE, true);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * @inheritDoc
	 */
	public function process (obj : Object, ci : ClassInfo, destroyCommands : CommandChain) : void {
		if (!(obj is LogFactory)) {
			throw new ConfigurationError("Can only process LogFactory instances");
		}
		var factory:LogFactory = LogFactory(obj);
		
		var name:String = getAttributeValue("name");
		var level:LogLevel = getAttributeValue("level");
		factory.addLogLevel(name, level);
	}
	
	
}

}

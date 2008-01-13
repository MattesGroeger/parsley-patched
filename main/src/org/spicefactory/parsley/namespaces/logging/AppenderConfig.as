package org.spicefactory.parsley.namespaces.logging {
import org.spicefactory.lib.logging.LogLevel;
import org.spicefactory.lib.logging.Appender;
import org.spicefactory.lib.logging.LogFactory;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.converter.LogLevelConverter;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the custom <code>appender</code> tag.
 * 
 * @author Jens Halm
 */
public class AppenderConfig extends AbstractElementConfig implements ObjectProcessorConfig {
	
	
	private var context:ApplicationContext;
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("ref", StringConverter.INSTANCE, true);
			ep.addAttribute("threshold", LogLevelConverter.INSTANCE, false, LogLevel.TRACE);
			_elementProcessor = ep;
		}
		return _elementProcessor;
	}
	
	/**
	 * @inheritDoc
	 */
	public override function parse (node:XML, context:ApplicationContext) : void {
		super.parse(node, context);
		this.context = context;
	}
	
	/**
	 * @inheritDoc
	 */
	public function process (obj : Object, ci : ClassInfo, destroyCommands : CommandChain) : void {
		if (!(obj is LogFactory)) {
			throw new ConfigurationError("Can only process LogFactory instances");
		}
		var factory:LogFactory = LogFactory(obj);
		
		var ref:String = getAttributeValue("ref");
		var appCandidate:Object = context.getObject(ref);
		if (!(appCandidate is Appender)) {
			throw new ConfigurationError("Object with id " + ref + " does not exist or does not" +
				" implement Appender");
		}
		var app:Appender = Appender(appCandidate);
		app.threshold = getAttributeValue("threshold");
		factory.addAppender(app);
	}
	
	
}

}

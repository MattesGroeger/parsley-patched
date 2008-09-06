package org.spicefactory.parsley.namespaces.cinnamon {
import flash.utils.Dictionary;

import org.spicefactory.cinnamon.client.ServiceChannel;
import org.spicefactory.cinnamon.client.ServiceProxy;
import org.spicefactory.cinnamon.client.support.AbstractServiceBase;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.ClassInfoConverter;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.reflect.converter.UintConverter;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.FactoryMetadata;
import org.spicefactory.parsley.context.factory.ObjectFactoryConfig;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the custom <code>service</code> tag.
 * 
 * @author Jens Halm
 */
public class ServiceConfig extends AbstractElementConfig implements ObjectFactoryConfig {
	
	
	private var context:ApplicationContext;
	
	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			ep.addAttribute("id", StringConverter.INSTANCE, true);
			ep.addAttribute("name", StringConverter.INSTANCE, false);
			ep.addAttribute("type", new ClassInfoConverter(ClassInfo.forClass(AbstractServiceBase), domain), true);
			ep.addAttribute("channel", StringConverter.INSTANCE, true);
			ep.addAttribute("timeout", UintConverter.INSTANCE, false, 0);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function parseRootObject (node : XML, context : ApplicationContext) : FactoryMetadata {
		this.context = context;
		parse(node, context);
		return new FactoryMetadata(getAttributeValue("id"), true, true);
	}
	
	/**
	 * @inheritDoc
	 */
	public function parseNestedObject (node : XML, context : ApplicationContext) : void {
		this.context = context;
		parse(node, context);
	}
	
	/**
	 * @inheritDoc
	 */
	public function createObject () : Object {
		var service:Object = getAttributeValue("type").newInstance([]);
		
		var channelRef:Object = context.getObject(getAttributeValue("channel"));
		if (!(channelRef is ServiceChannel)) {
			throw new ConfigurationError("Object with id " + getAttributeValue("channel")
				+ " does not implement ServiceChannel");
		}
		var channel:ServiceChannel = ServiceChannel(channelRef);
		
		var name:String = getAttributeValue("name");
		if (name == null) {
			name = getAttributeValue("id");
		}
		
		var proxy:ServiceProxy = channel.createProxy(name, service);
		proxy.timeout = getAttributeValue("timeout");
		
		return service;
	}

	/**
	 * @inheritDoc
	 */
	public function get type () : ClassInfo {
		return getAttributeValue("type");
	}
	
	
}

}

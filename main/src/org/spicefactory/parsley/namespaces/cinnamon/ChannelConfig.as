package org.spicefactory.parsley.namespaces.cinnamon {
import flash.utils.Dictionary;

import org.spicefactory.cinnamon.client.NetConnectionServiceChannel;
import org.spicefactory.cinnamon.client.ServiceChannel;
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
 * Represents the custom <code>channel</code> tag.
 * 
 * @author Jens Halm
 */
public class ChannelConfig extends AbstractElementConfig implements ObjectFactoryConfig {


	private static var _elementProcessor:Dictionary = new Dictionary();
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor[domain] == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.setSingleArrayMode(0);
			ep.addAttribute("id", StringConverter.INSTANCE, true);
			ep.addAttribute("type", new ClassInfoConverter(ClassInfo.forClass(ServiceChannel), domain),
				 false, ClassInfo.forClass(NetConnectionServiceChannel));
			ep.addAttribute("url", StringConverter.INSTANCE, true);
			ep.addAttribute("timeout", UintConverter.INSTANCE, false, 0);
			_elementProcessor[domain] = ep;
		}
		return _elementProcessor[domain];
	}
	
	
	/**
	 * @inheritDoc
	 */
	public function parseRootObject (node : XML, context : ApplicationContext) : FactoryMetadata {
		parse(node, context);
		return new FactoryMetadata(getAttributeValue("id"), true, true);
	}
	
	/**
	 * @inheritDoc
	 */
	public function parseNestedObject (node : XML, context : ApplicationContext) : void {
		throw new ConfigurationError("Channels must be defined as a root object configuration");
	}
	
	/**
	 * @inheritDoc
	 */
	public function createObject () : Object {
		var channelType:ClassInfo = getAttributeValue("type");
		var channel:ServiceChannel = ServiceChannel(channelType.newInstance([]));
		channel.serviceUrl = getAttributeValue("url");
		channel.timeout = getAttributeValue("timeout");
		return channel;
	}

	/**
	 * @inheritDoc
	 */
	public function get type () : ClassInfo {
		return ClassInfo.forClass(ServiceChannel);
	}
	
	
}

}

package org.spicefactory.parsley.namespaces.cinnamon {
import org.spicefactory.cinnamon.client.ServiceOperation;
import org.spicefactory.cinnamon.client.ServiceProxy;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.converter.StringConverter;
import org.spicefactory.lib.util.CommandChain;
import org.spicefactory.parsley.context.ApplicationContext;
import org.spicefactory.parsley.context.ConfigurationError;
import org.spicefactory.parsley.context.factory.ObjectProcessorConfig;
import org.spicefactory.parsley.context.tree.AbstractElementConfig;
import org.spicefactory.parsley.context.xml.DefaultElementProcessor;
import org.spicefactory.parsley.context.xml.ElementProcessor;

/**
 * Represents the custom <code>operation-listener</code> tag.
 * 
 * @author Jens Halm
 */
public class OperationListenerConfig extends AbstractElementConfig implements ObjectProcessorConfig {
	
	
	private var context:ApplicationContext;
	
	private static var _elementProcessor:ElementProcessor;
	
	/**
	 * @private
	 */
	protected override function getElementProcessor () : ElementProcessor {
		if (_elementProcessor == null) {
			var ep:DefaultElementProcessor = new DefaultElementProcessor();
			ep.addAttribute("service", StringConverter.INSTANCE, true);
			ep.addAttribute("operation", StringConverter.INSTANCE, true);
			ep.addAttribute("event-type", StringConverter.INSTANCE, true);
			ep.addAttribute("method", StringConverter.INSTANCE, true);
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
		var serviceId:String = getAttributeValue("service");
		var operation:String = getAttributeValue("operation");
		var eventType:String = getAttributeValue("eventType");
		var method:String = getAttributeValue("method");
		if (!(obj[method] is Function)) {
			throw new ConfigurationError("Object does not contain a method with name " + method);
		} 
		var listener:Function = obj[method];
		
		var service:Object = context.getObject(serviceId);
		if (service == null) {
			throw new ConfigurationError("No service available with id " + serviceId);
		}
		
		var proxy : ServiceProxy = ServiceProxy.forService(service);
		var op:ServiceOperation = proxy.getOperation(operation);
		if (op == null) {
			throw new ConfigurationError("No operation with name " + operation
				+ " in service with id " + serviceId);
		}
		op.addEventListener(eventType, listener);
	}
	
}

}

package org.spicefactory.parsley.tag.messaging {
import org.spicefactory.parsley.config.ObjectDefinitionDecorator;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;

[Metadata(name="CommandResult", types="method", multiple="true")]

/**
 * Represents a Metadata, MXML or XML tag that can be used on methods which wish to be invoked when
 * the result of a matching asynchronous command execution has been received.
 * 
 * @author Jens Halm
 */
public class CommandResultDecorator extends MessageReceiverDecoratorBase implements ObjectDefinitionDecorator {
	
	
	[Target]
	/**
	 * The name of the method that wishes to handle the message.
	 */
	public var method:String;
	
	
	public function decorate (builder:ObjectDefinitionBuilder) : void {
		builder
			.method(method)
				.commandResult()
					.scope(scope)
					.type(type)
					.selector(selector)
					.order(order);
	}
	
}
}

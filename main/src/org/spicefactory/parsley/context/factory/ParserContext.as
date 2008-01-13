package org.spicefactory.parsley.context.factory {
import org.spicefactory.parsley.context.ConfigurationError;

/**
 * Context Class that gives access to the currently active object configuration during
 * parse methods of custom tags. Also considers nested object configurations.
 * 
 * @author Jens Halm
 */
public class ParserContext {
	
	
	private static var contextStack:Array = new Array();
	
	
	/**
	 * Pushes the specified contextual information on the stack.
	 * 
	 * @param context the <code>ApplicationContext</code> that belongs to the currently processed element
	 * @param config the configuration of the currently processed element
	 * @param attributes the attributes extracted from the currently processed template client node
	 */
	public static function pushParserContext (obj:Object) : void {
		contextStack.push(obj);
	}
	
	/**
	 * Pops the contextual information from the top of the stack.
	 */
	public static function popTemplateContext () : void {
		if (contextStack.length == 0) {
			throw new ConfigurationError("Internal error: Attempt to pop empty context stack");
		}
		contextStack.pop();
	}
	
	/**	
	 * Returns the active configuration instance from the top of the stack.
	 * The returned object will either implement <code>RootObjectFactoryConfig</code>
	 * or <code>NestedObjectFactoryConfig</code>.
	 * 
	 * @return the <code>ElementConfig</code> instance from the top of the stack
	 */
	public static function getActiveConfig () : Object {
		if (contextStack.length == 0) {
			throw new ConfigurationError("ParserContext stack is empty");
		}
		return contextStack[contextStack.length - 1];
	}
}
}

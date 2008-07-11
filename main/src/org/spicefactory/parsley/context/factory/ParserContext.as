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
	 * Pushes the specified contextual information on the stack. The specified object
	 * should implement either <code>RootObjectFactoryConfig</code>
	 * or <code>NestedObjectFactoryConfig</code>.
	 * 
	 * @param obj the currently processed object configuration
	 */
	public static function pushParserContext (obj:ElementConfig) : void {
		contextStack.push(obj);
	}
	
	/**
	 * Pops the contextual information from the top of the stack.
	 */
	public static function popParserContext () : void {
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
	public static function getActiveConfig () : ElementConfig {
		if (contextStack.length == 0) {
			throw new ConfigurationError("ParserContext stack is empty");
		}
		return contextStack[contextStack.length - 1];
	}
}
}

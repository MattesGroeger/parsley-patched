package org.spicefactory.parsley.core.registry.builder.impl {
import org.spicefactory.lib.logging.LogContext;
import org.spicefactory.lib.logging.Logger;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.core.errors.ContextError;
import org.spicefactory.parsley.core.registry.DecoratorAssembler;
import org.spicefactory.parsley.core.registry.ObjectDefinition;
import org.spicefactory.parsley.core.registry.ObjectDefinitionDecorator;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.core.registry.RootObjectDefinition;

import flash.utils.getQualifiedClassName;

/**
 * @author Jens Halm
 */
public class AbstractObjectDefinitionBuilder {
	
	
	
	private static const log:Logger = LogContext.getLogger(AbstractObjectDefinitionBuilder);
	
	
	
	private var _type:ClassInfo;
	private var _registry:ObjectDefinitionRegistry;
	
	protected var decorators:Array = new Array();
	
	
	function AbstractObjectDefinitionBuilder (type:ClassInfo, registry:ObjectDefinitionRegistry) {
		_type = type;
		_registry = registry;
	}

	
	protected function get type () : ClassInfo {
		return _type;
	}
	
	protected function get registry () : ObjectDefinitionRegistry {
		return _registry;
	}
	
	
	/**
	 * Processes the decorators for this factory. This implementation processes all decorators obtained
	 * through the <code>decoratorAssemblers</code> property in the specified registry (usually one assembler processing metadata tags)
	 * along with decorators added to the <code>decorators</code>
	 * property explicitly, possibly through some additional configuration mechanism like MXML or XML.
	 * 
	 * @param registry the registry the definition belongs to
	 * @param definition the definition to process
	 * @return the resulting definition (possibly the same instance that was passed to this method)
	 */
	protected function processDecorators (registry:ObjectDefinitionRegistry, definition:ObjectDefinition) : ObjectDefinition {
		var decorators:Array = new Array();
		for each (var assembler:DecoratorAssembler in registry.decoratorAssemblers) {
			decorators = decorators.concat(assembler.assemble(definition.type));
		}
		decorators = decorators.concat(this.decorators);
		var errors:Array = new Array();
		var finalDefinition:ObjectDefinition = definition;
		for each (var decorator:ObjectDefinitionDecorator in decorators) {
			try {
				var newDef:ObjectDefinition = decorator.decorate(definition, registry);
				if (newDef != finalDefinition) {
					validateDefinitionReplacement(definition, newDef, decorator);
					finalDefinition = newDef;
				}
			}
			catch (e:Error) {
				var msg:String = "Error applying " + decorator;
				log.error(msg + "{0}", e);
				errors.push(msg + ": " + e.message);
			}
		}
		if (errors.length > 0) {
			throw new ContextError("One or more errors processing " + definition + ":\n " + errors.join("\n "));
		} 
		return finalDefinition;
	}

	private function validateDefinitionReplacement (oldDef:ObjectDefinition, newDef:ObjectDefinition, 
			decorator:ObjectDefinitionDecorator) : void {
		// we cannot allow "downgrades"
		if (oldDef is RootObjectDefinition && (!(newDef is RootObjectDefinition))) {
			throw new ContextError("Decorator of type " + getQualifiedClassName(decorator) 
					+ " attempts to downgrade a RootObjectDefinition to " + getQualifiedClassName(newDef));
		}
	}
	
	
}
}

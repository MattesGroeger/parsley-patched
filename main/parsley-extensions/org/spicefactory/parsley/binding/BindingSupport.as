package org.spicefactory.parsley.binding {
import org.spicefactory.lib.reflect.Metadata;
import org.spicefactory.parsley.binding.decorator.PublishDecorator;
import org.spicefactory.parsley.binding.decorator.PublishSubscribeDecorator;
import org.spicefactory.parsley.binding.decorator.SubscribeDecorator;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;

/**
 * Provides a static method to initalize the decoupled binding facility.
 * Can be used as a child tag of a <ContextBuilder> tag in MXML alternatively.
 * The core Parsley distribution automatically includes this extension, thus
 * there is usually no need to explicitly initialize it in applications.
 * 
 * @author Jens Halm
 */
public class BindingSupport {
	
	
	private static var initialized:Boolean = false;
	
	
	/**
	 * Initializes the support for decoupled bindings.
	 * Installs the Publish, Subscribe and PublishSubscribe tags for metadata, MXML and XML.
	 * Must be invoked before a <code>ContextBuilder</code> is used for the first time.
	 * 
	 * <p>The core Parsley distribution automatically includes this extension, thus
 	 * there is usually no need to explicitly initialize it in applications.</p>
  	 */
	public static function initialize () : void {
		if (initialized) return;
		
		Metadata.registerMetadataClass(SubscribeDecorator);
		Metadata.registerMetadataClass(PublishDecorator);
		Metadata.registerMetadataClass(PublishSubscribeDecorator);
		
		GlobalFactoryRegistry.instance.scopeExtensions.addExtension(new BindingManagerFactory());
		
		initialized = true;
	}
}
}

import org.spicefactory.parsley.binding.impl.DefaultBindingManager;
import org.spicefactory.parsley.core.factory.ScopeExtensionFactory;

class BindingManagerFactory implements ScopeExtensionFactory {

	public function create () : Object {
		return new DefaultBindingManager();
	}
	
}

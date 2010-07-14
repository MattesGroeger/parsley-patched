package org.spicefactory.parsley.flash.binding {
import org.spicefactory.lib.reflect.Metadata;
import org.spicefactory.parsley.binding.decorator.SubscribeDecorator;
import org.spicefactory.parsley.core.factory.impl.GlobalFactoryRegistry;

/**
 * Provides a static method to initalize the decoupled binding facility.
 * Can be used as a child tag of a <ContextBuilder> tag in MXML alternatively.
 * The core Parsley distribution automatically includes this extension, thus
 * there is usually no need to explicitly initialize it in applications.
 * This implementation does not rely on the Flex Binding facility, so it can be
 * used in Flash applications.
 * 
 * @author Jens Halm
 */
public class FlashBindingSupport {
	
	
	private static var initialized:Boolean = false;
	
	
	/**
	 * Initializes the support for decoupled bindings.
	 * Installs the Publish, Subscribe and PublishSubscribe tags for metadata, MXML and XML.
	 * Must be invoked before a <code>ContextBuilder</code> is used for the first time.
	 */
	public static function initialize () : void {
		if (initialized) return;
		
		Metadata.registerMetadataClass(SubscribeDecorator);
		Metadata.registerMetadataClass(FlashPublishDecorator);
		Metadata.registerMetadataClass(FlashPublishSubscribeDecorator);
		
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

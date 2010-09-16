package org.spicefactory.parsley.binding {
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.parsley.binding.model.AnimalHolder;
import org.spicefactory.parsley.binding.model.Cat;
import org.spicefactory.parsley.binding.model.CatHolder;
import org.spicefactory.parsley.binding.model.StringHolder;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.ContextUtil;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.core.scope.ScopeRegistry;
import org.spicefactory.parsley.core.scope.impl.DefaultScopeRegistry;

/**
 * @author Jens Halm
 */
public class BindingTestBase extends ContextTestBase {
	
	
	
	private var context:Context;
	
	
	public override function setUp () : void {
		context = bindingContext;
		checkState(context);
	}
	
	protected function get bindingContext () : Context {
		throw new AbstractMethodError();
	}
	
	protected function addConfig (builder:CompositeContextBuilder) : void {
		throw new AbstractMethodError();
	}
	
	
	public function testPublish () : void {
		var pub:CatHolder = context.getObject("publish") as CatHolder;
		var sub:CatHolder = context.getObject("subscribe") as CatHolder;
		assertNull("Unexpected subsciber value", sub.value);
		pub.value = new Cat();
		assertNotNull("Expected non-null subsciber value", sub.value);
	}
	
	public function testPublishSubscribe() : void {
		var pub1:CatHolder = context.getObject("pubsub") as CatHolder;
		var pub2:CatHolder = context.getObject("pubsub") as CatHolder;
		var sub:CatHolder = context.getObject("subscribe") as CatHolder;
		assertNull("Unexpected subsciber value", sub.value);
		var cat1:Cat = new Cat();
		var cat2:Cat = new Cat();
		pub1.value = cat1;
		assertEquals("Unexpected subsciber value", cat1, sub.value);
		assertEquals("Unexpected subsciber value", cat1, pub1.value);
		assertEquals("Unexpected subsciber value", cat1, pub2.value);
		pub2.value = cat2;
		assertEquals("Unexpected subsciber value", cat2, sub.value);
		assertEquals("Unexpected subsciber value", cat2, pub1.value);
		assertEquals("Unexpected subsciber value", cat2, pub2.value);
	}
	
	public function testTwoPublish () : void {
		context.getObject("publish");
		context.getObject("subscribe");
		try {
			context.getObject("publish");
		}
		catch (e:Error) {
			return;
		}
		fail("Expected Error due two conflicting publishers");
	}
	
	public function testPublishId () : void {
		var pub:CatHolder = context.getObject("publish") as CatHolder;
		var pubId:CatHolder = context.getObject("publishId") as CatHolder;
		var sub:CatHolder = context.getObject("subscribe") as CatHolder;
		var subId:CatHolder = context.getObject("subscribeId") as CatHolder;
		assertNull("Unexpected subsciber value", sub.value);
		assertNull("Unexpected subsciber value", subId.value);
		var cat1:Cat = new Cat();
		var cat2:Cat = new Cat();
		pub.value = cat1;
		assertEquals("Unexpected subsciber value", cat1, sub.value);
		assertNull("Unexpected subsciber value", subId.value);
		pubId.value = cat2;
		assertEquals("Unexpected subsciber value", cat1, sub.value);
		assertEquals("Unexpected subsciber value", cat2, subId.value);
	}
	
	public function testPublishPolymorphically () : void {
		var pub:CatHolder = context.getObject("publish") as CatHolder;
		var sub:AnimalHolder = context.getObject("animalSubscribe") as AnimalHolder;
		assertNull("Unexpected subsciber value", sub.value);
		pub.value = new Cat();
		assertNotNull("Expected non-null subsciber value", sub.value);
	}
	
	public function testScope () : void {
		var pub:CatHolder = context.getObject("publishLocal") as CatHolder;
		var sub:CatHolder = context.getObject("subscribe") as CatHolder;
		var subLocal:CatHolder = context.getObject("subscribeLocal") as CatHolder;
		assertNull("Unexpected subsciber value", sub.value);
		assertNull("Unexpected subsciber value", subLocal.value);
		pub.value = new Cat();
		assertNull("Unexpected subsciber value", sub.value);
		assertNotNull("Expected non-null subsciber value", subLocal.value);
	}
	
	public function testContextDestruction () : void {
		var pub:CatHolder = context.getObject("publish") as CatHolder;
		var sub:CatHolder = context.getObject("subscribe") as CatHolder;
		assertNull("Unexpected subsciber value", sub.value);
		pub.value = new Cat();
		assertNotNull("Expected non-null subsciber value", sub.value);
		context.destroy();
		assertNull("Unexpected subsciber value", sub.value);
	}
	
	public function testPublishManaged () : void {
		var pub:CatHolder = context.getObject("publish") as CatHolder;
		var pubMgd:CatHolder = context.getObject("publishManaged") as CatHolder;
		var added:Array = new Array();
		var listener:Function = function (c:Cat) : void {
			added.push(c);
		};
		var removed:Array = new Array();
		var listener2:Function = function (c:Cat) : void {
			removed.push(c);
		};
		context.scopeManager.getScope(ScopeName.LOCAL).objectLifecycle.addListener(Cat, ObjectLifecycle.POST_INIT, listener);
		context.scopeManager.getScope(ScopeName.LOCAL).objectLifecycle.addListener(Cat, ObjectLifecycle.PRE_DESTROY, listener2);
		var cat1:Cat = new Cat();
		var cat2:Cat = new Cat();
		pub.value = cat1;
		pubMgd.value = cat2;
		assertEquals("Expected exactly one managed object", 1, added.length);
		assertEquals("Unexpected managed object", cat2, added[0]);
		pubMgd.value = null;
		assertEquals("Expected exactly one removed object", 1, removed.length);
		assertEquals("Unexpected removed object", cat2, removed[0]);
	}
	
	public function testPublishPersistent () : void {
		var reg:ScopeRegistry = ContextUtil.globalScopeRegistry;
		DefaultScopeRegistry(reg).reset();
		DictionaryPersistenceService.reset();
		DictionaryPersistenceService.putStoredValue("local0", String, "test", "A");
		
		var builder:CompositeContextBuilder = new DefaultCompositeContextBuilder();
		builder.factories.scopeExtensions.addExtension(new TestPersistenceManagerFactory());
		addConfig(builder);
		var context:Context = builder.build();
		
		var pub1:StringHolder = context.getObject("publishPersistent") as StringHolder;
		var pub2:StringHolder = context.getObject("publishPersistent") as StringHolder;
		assertEquals("Unexpected persisted value", "A", DictionaryPersistenceService.getStoredValue("local0", String, "test"));
		pub1.value = "B";
		assertEquals("Unexpected subscriber value", "B", pub2.value);
		assertEquals("Unexpected change count", 1, DictionaryPersistenceService.changeCount);
		assertEquals("Unexpected persisted value", "B", DictionaryPersistenceService.getStoredValue("local0", String, "test"));
		context.destroy();
		assertEquals("Unexpected change count", 1, DictionaryPersistenceService.changeCount);
		assertEquals("Unexpected persisted value", "B", DictionaryPersistenceService.getStoredValue("local0", String, "test"));
	}
}
}

import org.spicefactory.parsley.binding.DictionaryPersistenceService;
import org.spicefactory.parsley.core.factory.ScopeExtensionFactory;

class TestPersistenceManagerFactory implements ScopeExtensionFactory {

	public function create() : Object {
		return new DictionaryPersistenceService();
	}
}

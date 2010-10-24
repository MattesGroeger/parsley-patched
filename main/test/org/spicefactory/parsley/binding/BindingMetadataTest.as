package org.spicefactory.parsley.binding {
import org.spicefactory.parsley.binding.model.AnimalSubscribeMetadata;
import org.spicefactory.parsley.binding.model.Cat;
import org.spicefactory.parsley.binding.model.CatPubSubMetadata;
import org.spicefactory.parsley.binding.model.CatPublishCustomMetadata;
import org.spicefactory.parsley.binding.model.CatPublishIdMetadata;
import org.spicefactory.parsley.binding.model.CatPublishLocalMetadata;
import org.spicefactory.parsley.binding.model.CatPublishManagedMetadata;
import org.spicefactory.parsley.binding.model.CatPublishMetadata;
import org.spicefactory.parsley.binding.model.CatSubscribeCustomMetadata;
import org.spicefactory.parsley.binding.model.CatSubscribeIdMetadata;
import org.spicefactory.parsley.binding.model.CatSubscribeLocalMetadata;
import org.spicefactory.parsley.binding.model.CatSubscribeMetadata;
import org.spicefactory.parsley.binding.model.StringPublishPersistentMetadata;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.builder.CompositeContextBuilder;
import org.spicefactory.parsley.core.builder.impl.DefaultCompositeContextBuilder;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.context.ContextUtil;
import org.spicefactory.parsley.core.context.DynamicObject;
import org.spicefactory.parsley.core.errors.ContextBuilderError;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.core.scope.ScopeRegistry;
import org.spicefactory.parsley.core.scope.impl.DefaultScopeRegistry;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.runtime.RuntimeContextBuilder;
import org.spicefactory.parsley.runtime.processor.RuntimeConfigurationProcessor;

/**
 * @author Jens Halm
 */
public class BindingMetadataTest extends ContextTestBase {
	
	
	public function testPublish () : void {
		var pub:CatPublishMetadata = new CatPublishMetadata();
		var sub:CatSubscribeMetadata = new CatSubscribeMetadata();
		RuntimeContextBuilder.build([pub,sub]);
		assertNull("Unexpected subsciber value", sub.value);
		pub.value = new Cat();
		assertNotNull("Expected non-null subsciber value", sub.value);
	}
	
	public function testPublishSubscribe() : void {
		var pub1:CatPubSubMetadata = new CatPubSubMetadata();
		var pub2:CatPubSubMetadata = new CatPubSubMetadata();
		var sub:CatSubscribeMetadata = new CatSubscribeMetadata();
		RuntimeContextBuilder.build([pub1, pub2, sub]);
		assertNull("Unexpected subsciber value", sub.value);
		var cat1:Cat = new Cat();
		var cat2:Cat = new Cat();
		pub1.value = cat1;
		assertEquals("Unexpected subsciber value", cat1, sub.value);
		assertEquals("Unexpected publisher value", cat1, pub1.value);
		assertEquals("Unexpected publisher value", cat1, pub2.value);
		pub2.value = cat2;
		assertEquals("Unexpected subsciber value", cat2, sub.value);
		assertEquals("Unexpected publisher value", cat2, pub1.value);
		assertEquals("Unexpected publisher value", cat2, pub2.value);
	}
	
	public function testPublishSubscribeLifecycle() : void {
		var pub1:CatPubSubMetadata = new CatPubSubMetadata();
		var pub2:CatPubSubMetadata = new CatPubSubMetadata();
		var sub:CatSubscribeMetadata = new CatSubscribeMetadata();
		var context:Context = RuntimeContextBuilder.build([sub]);
		assertNull("Unexpected subsciber value", sub.value);
		var cat1:Cat = new Cat();
		var cat2:Cat = new Cat();
		pub1.value = cat1;
		var dyn1:DynamicObject = context.addDynamicObject(pub1);
		assertEquals("Unexpected subsciber value", cat1, sub.value);
		assertEquals("Unexpected publisher value", cat1, pub1.value);
		assertEquals("Unexpected publisher value", null, pub2.value);
		pub2.value = cat2;
		var dyn2:DynamicObject = context.addDynamicObject(pub2);
		assertEquals("Unexpected subsciber value", cat1, sub.value);
		assertEquals("Unexpected publisher value", cat1, pub1.value);
		assertEquals("Unexpected publisher value", cat1, pub2.value);
		pub2.value = cat2;
		assertEquals("Unexpected subsciber value", cat2, sub.value);
		assertEquals("Unexpected publisher value", cat2, pub1.value);
		assertEquals("Unexpected publisher value", cat2, pub2.value);
		dyn1.remove();
		assertEquals("Unexpected subsciber value", cat2, sub.value);
		assertEquals("Unexpected publisher value", null, pub1.value);
		assertEquals("Unexpected publisher value", cat2, pub2.value);
		dyn2.remove();
		assertEquals("Unexpected subsciber value", null, sub.value);
		assertEquals("Unexpected publisher value", null, pub1.value);
		assertEquals("Unexpected publisher value", null, pub2.value);
		
	}
	
	public function testTwoPublish () : void {
		var pub1:CatPublishMetadata = new CatPublishMetadata();
		var pub2:CatPublishMetadata = new CatPublishMetadata();
		var sub:CatSubscribeMetadata = new CatSubscribeMetadata();
		try {
			RuntimeContextBuilder.build([pub1, pub2, sub]);
		}
		catch (e:ContextBuilderError) {
			return;
		}
		fail("Expected Error due two conflicting publishers");
	}
	
	public function testPublishId () : void {
		var pub:CatPublishMetadata = new CatPublishMetadata();
		var pubId:CatPublishIdMetadata = new CatPublishIdMetadata();
		var sub:CatSubscribeMetadata = new CatSubscribeMetadata();
		var subId:CatSubscribeIdMetadata = new CatSubscribeIdMetadata();
		RuntimeContextBuilder.build([pub, pubId, sub, subId]);
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
		var pub:CatPublishMetadata = new CatPublishMetadata();
		var sub:AnimalSubscribeMetadata = new AnimalSubscribeMetadata();
		RuntimeContextBuilder.build([pub,sub]);
		assertNull("Unexpected subsciber value", sub.value);
		pub.value = new Cat();
		assertNotNull("Expected non-null subsciber value", sub.value);
	}
	
	public function testLocalScope () : void {
		var pub:CatPublishLocalMetadata = new CatPublishLocalMetadata();
		var sub:CatSubscribeMetadata = new CatSubscribeMetadata();
		var subLocal:CatSubscribeLocalMetadata = new CatSubscribeLocalMetadata();
		RuntimeContextBuilder.build([pub, sub, subLocal]);
		assertNull("Unexpected subsciber value", sub.value);
		assertNull("Unexpected subsciber value", subLocal.value);
		pub.value = new Cat();
		assertNull("Unexpected subsciber value", sub.value);
		assertNotNull("Expected non-null subsciber value", subLocal.value);
	}
	
	public function testCustomScope () : void {
		var pub:CatPublishCustomMetadata = new CatPublishCustomMetadata();
		var sub:CatSubscribeMetadata = new CatSubscribeMetadata();
		var subCustom:CatSubscribeCustomMetadata = new CatSubscribeCustomMetadata();
		ContextBuilder.newSetup()
			.scope("custom")
			.newBuilder()
				.object(pub)
				.object(sub)
				.object(subCustom)
				.build();
		assertNull("Unexpected subsciber value", sub.value);
		assertNull("Unexpected subsciber value", subCustom.value);
		pub.value = new Cat();
		assertNull("Unexpected subsciber value", sub.value);
		assertNotNull("Expected non-null subsciber value", subCustom.value);
	}
	
	public function testContextDestruction () : void {
		var pub:CatPublishMetadata = new CatPublishMetadata();
		var sub:CatSubscribeMetadata = new CatSubscribeMetadata();
		var context:Context = RuntimeContextBuilder.build([pub,sub]);
		assertNull("Unexpected subsciber value", sub.value);
		pub.value = new Cat();
		assertNotNull("Expected non-null subsciber value", sub.value);
		context.destroy();
		assertNull("Unexpected subsciber value", sub.value);
	}
	
	public function testPublishManaged () : void {
		var pub:CatPublishMetadata = new CatPublishMetadata();
		var pubMgd:CatPublishManagedMetadata = new CatPublishManagedMetadata();
		var context:Context = RuntimeContextBuilder.build([pub, pubMgd]);
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
		
		var pub1:StringPublishPersistentMetadata = new StringPublishPersistentMetadata();
		var pub2:StringPublishPersistentMetadata = new StringPublishPersistentMetadata();
		
		var context:Context = ContextBuilder
			.newSetup()
				.scopeExtensions(true).factory(new TestPersistenceManagerFactory())
				.newBuilder()
					.object(pub1)
					.object(pub2)
					.build();
		
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

package org.spicefactory.parsley.context.scope {
import org.hamcrest.assertThat;
import org.hamcrest.collection.arrayWithSize;
import org.hamcrest.core.not;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.notNullValue;
import org.hamcrest.object.nullValue;
import org.hamcrest.object.sameInstance;
import org.spicefactory.parsley.asconfig.ActionScriptConfig;
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.context.scope.model.CustomScopeReceiver;
import org.spicefactory.parsley.context.scope.model.LocalReceiver;
import org.spicefactory.parsley.context.scope.model.PassiveSender;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.lifecycle.ObjectLifecycle;
import org.spicefactory.parsley.core.scope.Scope;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.core.state.GlobalScopeState;
import org.spicefactory.parsley.core.state.GlobalState;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.util.XmlContextUtil;

import mx.containers.Box;
import mx.containers.HBox;
import mx.containers.VBox;

import flash.events.Event;
import flash.events.EventDispatcher;

/**
 * @author Jens Halm
 */
public class ScopeTest {
	
	
	private static const CUSTOM_SCOPE:String = "custom";
	

	[Test]
	public function localMessages () : void {
		var context:Context = ActionScriptContextBuilder.build(ScopeMessagingTestConfig);
		var r:LocalReceiver = context.getObjectByType(LocalReceiver) as LocalReceiver;
		assertThat(r.getCount(), equalTo(3));
		assertThat(r.getCount(Event, "global"), equalTo(1));
		assertThat(r.getCount(Event, "local"), equalTo(2));
	}
	
	[Test]
	public function customScope () : void {
		PassiveSender;
		var configA:XML = <objects xmlns="http://www.spicefactory.org/parsley">
  			<object id="senderA" type="org.spicefactory.parsley.context.scope.model.PassiveSender"/>
  		</objects>;
		var configB:XML = <objects xmlns="http://www.spicefactory.org/parsley">
  			<object id="senderB" type="org.spicefactory.parsley.context.scope.model.PassiveSender"/>
  		</objects>;
		var configC:XML = <objects xmlns="http://www.spicefactory.org/parsley">
  			<object id="senderC" type="org.spicefactory.parsley.context.scope.model.PassiveSender"/>
  			<object id="receiver" type="org.spicefactory.parsley.context.scope.model.CustomScopeReceiver"/>
  		</objects>;
  		var contextA:Context = XmlContextUtil.newContext(configA);
  		var contextB:Context = XmlContextUtil.newContext(configB, contextA, "custom");
  		var contextC:Context = XmlContextUtil.newContext(configC, contextB);
  		var senderA:EventDispatcher = contextC.getObject("senderA") as EventDispatcher;
  		var senderB:EventDispatcher = contextC.getObject("senderB") as EventDispatcher;
  		var senderC:EventDispatcher = contextC.getObject("senderC") as EventDispatcher;
  		var receiver:CustomScopeReceiver = contextC.getObjectByType(CustomScopeReceiver) as CustomScopeReceiver;
  		senderA.dispatchEvent(new Event("test"));
  		senderB.dispatchEvent(new Event("test"));
  		senderC.dispatchEvent(new Event("test"));
  		assertThat(receiver.getCount(), equalTo(6));
		assertThat(receiver.getCount(Event, "global"), equalTo(3));
		assertThat(receiver.getCount(Event, "custom"), equalTo(2));
		assertThat(receiver.getCount(Event, "local"), equalTo(1));
	}
	
	[Test]
	public function objectLifecycle () : void {
		HBox;
		VBox;
		var configA:XML = <objects xmlns="http://www.spicefactory.org/parsley">
  			<object type="mx.containers.HBox" lazy="true"/>
  			<object type="mx.containers.VBox" lazy="true"/>
  			<object type="mx.containers.Box" lazy="true"/>
  		</objects>;
		var configB:XML = <objects xmlns="http://www.spicefactory.org/parsley">
  			<object type="mx.containers.HBox" lazy="true"/>
  			<object type="mx.containers.VBox" lazy="true"/>
  			<object type="mx.containers.Box" lazy="true"/>
  		</objects>;
		var configC:XML = <objects xmlns="http://www.spicefactory.org/parsley">
  			<object type="mx.containers.HBox" lazy="true"/>
  			<object type="mx.containers.VBox" lazy="true"/>
  			<object type="mx.containers.Box" lazy="true"/>
  		</objects>;
  		var contextA:Context = XmlContextUtil.newContext(configA);
  		var contextB:Context = XmlContextUtil.newContext(configB, contextA, "custom");
  		var contextC:Context = XmlContextUtil.newContext(configC, contextB);
  		var counter:LifecycleEventCounter = new LifecycleEventCounter();
  		addListener(contextC, ScopeName.GLOBAL, counter.globalListener);
  		addListener(contextC, ScopeName.LOCAL, counter.localListener);
  		addListener(contextC, "custom", counter.customListener);
  		contextC.getAllObjectsByType(Box); // just trigger instantiation of lazy objects
  		assertThat(counter.getCount(), equalTo(30));
  		assertThat(counter.getCount(HBox), equalTo(12));
  		assertThat(counter.getCount(VBox), equalTo(12));
  		assertThat(counter.getCount(HBox, "local"), equalTo(2));
  		assertThat(counter.getCount(HBox, "custom"), equalTo(4));
  		assertThat(counter.getCount(HBox, "global"), equalTo(6));
  		assertThat(counter.getCount(Box, "local"), equalTo(1));
  		assertThat(counter.getCount(Box, "custom"), equalTo(2));
  		assertThat(counter.getCount(Box, "global"), equalTo(3));
	}
	
	private function addListener (context:Context, scopeName:String, f:Function) : void {
		var scope:Scope = context.scopeManager.getScope(scopeName);
  		scope.objectLifecycle.addListener(Box, ObjectLifecycle.PRE_INIT, f);
  		scope.objectLifecycle.addListener(HBox, ObjectLifecycle.PRE_INIT, f);
  		scope.objectLifecycle.addListener(VBox, ObjectLifecycle.PRE_INIT, f);
	}

	[Test]
	public function extensions () : void {
		var context:Context = ContextBuilder
		.newSetup()
			.scopeExtensions()
				.forType(ScopeTestExtension)
				.setImplementation(ScopeTestExtension)
			.newBuilder()
				.config(ActionScriptConfig.forClass(ScopeMessagingTestConfig))
				.build();
		
		var localExtension:ScopeTestExtension
				= context.scopeManager.getScope(ScopeName.LOCAL).extensions.forType(ScopeTestExtension) as ScopeTestExtension;
		var globalExtension:ScopeTestExtension
				= context.scopeManager.getScope(ScopeName.GLOBAL).extensions.forType(ScopeTestExtension) as ScopeTestExtension;
		assertThat(globalExtension, notNullValue());
		assertThat(localExtension, notNullValue());
		assertThat(localExtension, not(sameInstance(globalExtension)));
	}
	
	[Test]
	public function scopeRegistry () : void {
		var reg:Object = GlobalState.scopes;
		reg.reset();
		validateScopes(0, 0, 0);
		
		var root1:Context = ContextBuilder.newBuilder().build();
		validateScopes(1, 1, 0);
		validateUuids("global0", "local0");
		
		var child1:Context = ContextBuilder.newSetup().parent(root1).scope(CUSTOM_SCOPE).newBuilder().build();
		validateScopes(1, 2, 1);
		validateUuids("global0", "local0", "local1", "custom0");
		
		var child2:Context = ContextBuilder.newSetup().parent(root1).scope(CUSTOM_SCOPE, true, "foo").newBuilder().build();
		validateScopes(1, 3, 2);
		validateUuids("global0", "local0", "local1", "local2", "custom0", "foo");
		
		var grandChild:Context = ContextBuilder.newSetup().parent(child1).newBuilder().build();
		validateScopes(1, 4, 2);
		validateUuids("global0", "local0", "local1", "local2", "local3", "custom0", "foo");
		
		var root2:Context = ContextBuilder.newBuilder().build();
		validateScopes(2, 5, 2);
		validateUuids("global0", "global1", "local0", "local1", "local2", "local3", "local4", "custom0", "foo");
		
		child1.destroy();
		validateScopes(2, 3, 1);
		validateUuids("global0", "global1", "local0", "local2", "local4", "foo");
		validateUuidsRemoved("local1", "local3", "custom0");
		
		root1.destroy();
		validateScopes(1, 1, 0);
		validateUuids("global1", "local4");
		validateUuidsRemoved("global0", "local0", "local1", "local2", "local3", "custom0", "foo");
		
		root2.destroy();
		validateScopes(0, 0, 0);
		validateUuidsRemoved("global0", "global1", "local0", "local1", "local2", "local3", "local4", "custom0", "foo");
	}
	
	private function validateScopes (global:int, local:int, custom:int) : void {
		var reg:GlobalScopeState = GlobalState.scopes;
		assertThat(reg.getScopesByName(ScopeName.GLOBAL), arrayWithSize(global));
		assertThat(reg.getScopesByName(ScopeName.LOCAL), arrayWithSize(local));
		assertThat(reg.getScopesByName(CUSTOM_SCOPE), arrayWithSize(custom));
	}
	
	private function validateUuids (...uuids) : void {
		var reg:GlobalScopeState = GlobalState.scopes;
		for each (var uuid:String in uuids) {
			assertThat(reg.getScopeById(uuid), notNullValue());
		}
	}
	
	private function validateUuidsRemoved (...uuids) : void {
		var reg:GlobalScopeState = GlobalState.scopes;
		for each (var uuid:String in uuids) {
			assertThat(reg.getScopeById(uuid), nullValue());
		}
	}
}
}

import org.spicefactory.parsley.util.MessageCounter;

import mx.containers.Box;

class LifecycleEventCounter extends MessageCounter {
	public function globalListener (instance:Box) : void {
		addMessage(instance, "global");
	}
	public function localListener (instance:Box) : void {
		addMessage(instance, "local");
	}
	public function customListener (instance:Box) : void {
		addMessage(instance, "custom");
	}
}


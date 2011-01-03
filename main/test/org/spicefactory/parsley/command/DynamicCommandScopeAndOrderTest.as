package org.spicefactory.parsley.command {
import org.hamcrest.assertThat;
import org.hamcrest.object.equalTo;
import org.spicefactory.parsley.command.model.DynamicCommandObserverOrder;
import org.spicefactory.parsley.command.model.OrderBuilder;
import org.spicefactory.parsley.command.model.OrderedMixedScopeCompleteHandlers;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
import org.spicefactory.parsley.core.scope.ScopeName;
import org.spicefactory.parsley.dsl.ObjectDefinitionBuilder;
import org.spicefactory.parsley.dsl.context.ContextBuilder;
import org.spicefactory.parsley.dsl.messaging.impl.DynamicCommandBuilder;

/**
 * @author Jens Halm
 */
public class DynamicCommandScopeAndOrderTest {
	
	[Test]
	public function commandResultOrder () : void {
		if (!CommandTestBase.factory) {
			CommandTestBase.registerMockCommandFactory();
		}
		CommandTestBase.factory.reset();
		
		var order:OrderBuilder = new OrderBuilder();
		DynamicCommandObserverOrder.order = order;
		OrderedMixedScopeCompleteHandlers.order = order;
		
		var handlerParent:OrderedMixedScopeCompleteHandlers = new OrderedMixedScopeCompleteHandlers("-PAR");
		var handlerChild:OrderedMixedScopeCompleteHandlers = new OrderedMixedScopeCompleteHandlers("-CHI");
		var parentBuilder:ContextBuilder = ContextBuilder.newSetup().newBuilder();
		var def:DynamicObjectDefinition 
				= parentBuilder.objectDefinition().forClass(DynamicCommandObserverOrder).asDynamicObject().build();
		DynamicCommandBuilder.newBuilder(def).build();
		buildCompleteHandlers(parentBuilder, handlerParent, ["1", "3", "5", "7"]);
		var parent:Context = parentBuilder.build();
		var childBuilder:ContextBuilder = ContextBuilder.newSetup().parent(parent).newBuilder();
		buildCompleteHandlers(childBuilder, handlerChild, ["2", "4", "6"]);
		var child:Context = childBuilder.build();
		
		child.scopeManager.dispatchMessage("foo");
		assertThat(order.value, equalTo("-EXE"));
		CommandTestBase.factory.dispatchAll();
		assertThat(order.value, equalTo("-EXE-CHI:I-DYN-CHI:A-PAR:B-CHI:B-CHI:C-PAR:D-CHI:D"));
	}
	
	private function buildCompleteHandlers (contextBuilder:ContextBuilder, instance:Object, order:Array) : void {
		var builder:ObjectDefinitionBuilder = contextBuilder.objectDefinition().forInstance(instance);
		builder.method("handleLocalCommand").commandComplete().scope(ScopeName.LOCAL).order(order[0]);
		builder.method("handleGlobalCommand").commandComplete().order(order[1]);
		builder.method("handleLocalCommand2").commandComplete().scope(ScopeName.LOCAL).order(order[2]);
		if (order.length > 3) {
			builder.method("handleGlobalCommand2").commandComplete().order(order[3]);
		}
		else {
			builder.method("handleGlobalCommand2").commandComplete();
		}
		builder.method("interceptLocalCommand").commandComplete().scope(ScopeName.LOCAL);
		builder.asSingleton().register();
	}
}
}

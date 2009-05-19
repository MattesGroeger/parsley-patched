package org.spicefactory.parsley.core.decorator {
import org.spicefactory.parsley.core.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.Context;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.errors.ContextError;

/**
 * @author Jens Halm
 */
public class InjectionDecoratorTest extends ContextTestBase {
	
	
	public function testConstructorInjection () : void {
		
	}
	
	public function testConstructorInjectionWithMissingReqDep () : void {
		
	}
	
	public function testConstructorInjectionWithMissingOptDep () : void {
		
	}

	public function testPropertyTypeInjection () : void {
		var context:Context = ActionScriptContextBuilder.build(DecoratorTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["requiredPropertyInjection"], RequiredPropertyInjection);	
		var obj:RequiredPropertyInjection 
				= getAndCheckObject(context, "requiredPropertyInjection", RequiredPropertyInjection) as RequiredPropertyInjection;
		checkDependency(context, obj.dependency);
	}	

	public function testPropertyTypeInjectionWithMissingReqDep () : void {
		var context:Context = ActionScriptContextBuilder.build(DecoratorTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["missingPropertyInjection"], MissingPropertyInjection);
		try {
			context.getObject("missingPropertyInjection");		
		}
		catch (e:ContextError) {
			trace(e.getStackTrace());
			return;
		}
		fail("Expected ContextError for missing dependency");
	}
	
	public function testPropertyTypeInjectionWithMissingOptDep () : void {
		var context:Context = ActionScriptContextBuilder.build(DecoratorTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["optionalPropertyInjection"], OptionalPropertyInjection);	
		var obj:OptionalPropertyInjection 
				= getAndCheckObject(context, "optionalPropertyInjection", OptionalPropertyInjection) as OptionalPropertyInjection;
		assertNull("Expeced optional dependency to be missing", obj.dependency);		
	}

	public function testPropertyIdInjection () : void {
		
	}
	
	public function testPropertyIdInjectionWithMissingReqDep () : void {
		
	}	
	
	public function testPropertyIdInjectionWithMissingOptDep () : void {
		
	}	
	
	public function testMethodInjection () : void {
		
	}	
	
	public function testMethodInjectionWithMissingReqDep () : void {
		
	}
	
	public function testMethodInjectionWithMissingOptDep () : void {
		
	}	
	
	
	private function checkDependency (context:Context, dep:InjectedDependency) : void {
		assertNotNull("Missing dependency", dep);
		var depFromContainer:InjectedDependency	
				= getAndCheckObject(context, "injectedDependency", InjectedDependency) as InjectedDependency;
		assertEquals("Expected singleton dependency", depFromContainer, dep);
	}
	
	
}
}

package org.spicefactory.parsley.core.decorator.injection {
import org.spicefactory.parsley.asconfig.ActionScriptContextBuilder;
import org.spicefactory.parsley.core.ContextTestBase;
import org.spicefactory.parsley.core.context.Context;
import org.spicefactory.parsley.core.decorator.injection.InjectTestContainer;
import org.spicefactory.parsley.core.decorator.injection.InjectedDependency;
import org.spicefactory.parsley.core.decorator.injection.MissingConstructorInjection;
import org.spicefactory.parsley.core.decorator.injection.MissingMethodInjection;
import org.spicefactory.parsley.core.decorator.injection.MissingPropertyIdInjection;
import org.spicefactory.parsley.core.decorator.injection.MissingPropertyInjection;
import org.spicefactory.parsley.core.decorator.injection.OptionalMethodInjection;
import org.spicefactory.parsley.core.decorator.injection.OptionalPropertyIdInjection;
import org.spicefactory.parsley.core.decorator.injection.OptionalPropertyInjection;
import org.spicefactory.parsley.core.decorator.injection.RequiredConstructorInjection;
import org.spicefactory.parsley.core.decorator.injection.RequiredMethodInjection;
import org.spicefactory.parsley.core.decorator.injection.RequiredPropertyIdInjection;
import org.spicefactory.parsley.core.decorator.injection.RequiredPropertyInjection;
import org.spicefactory.parsley.core.errors.ContextError;

/**
 * @author Jens Halm
 */
public class InjectMetadataTagTest extends ContextTestBase {
	
	
	public function testConstructorInjection () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["requiredConstructorInjection"], RequiredConstructorInjection);	
		var obj:RequiredConstructorInjection 
				= getAndCheckObject(context, "requiredConstructorInjection", RequiredConstructorInjection) as RequiredConstructorInjection;
		checkDependency(context, obj.dependency);
	}
	
	public function testConstructorInjectionWithMissingReqDep () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["missingConstructorInjection"], MissingConstructorInjection);
		try {
			context.getObject("missingConstructorInjection");		
		}
		catch (e:ContextError) {
			trace(e.getStackTrace());
			return;
		}
		fail("Expected ContextError for missing dependency");				
	}
	
	public function testConstructorInjectionWithMissingOptDep () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["optionalMethodInjection"], OptionalMethodInjection);	
		var obj:OptionalMethodInjection 
				= getAndCheckObject(context, "optionalMethodInjection", OptionalMethodInjection) as OptionalMethodInjection;
		assertNull("Expected optional dependency to be missing", obj.dependency);				
	}

	public function testPropertyTypeInjection () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["requiredPropertyInjection"], RequiredPropertyInjection);	
		var obj:RequiredPropertyInjection 
				= getAndCheckObject(context, "requiredPropertyInjection", RequiredPropertyInjection) as RequiredPropertyInjection;
		checkDependency(context, obj.dependency);
	}	

	public function testPropertyTypeInjectionWithMissingReqDep () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
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
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["optionalPropertyInjection"], OptionalPropertyInjection);	
		var obj:OptionalPropertyInjection 
				= getAndCheckObject(context, "optionalPropertyInjection", OptionalPropertyInjection) as OptionalPropertyInjection;
		assertNull("Expeced optional dependency to be missing", obj.dependency);		
	}

	public function testPropertyIdInjection () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["requiredPropertyIdInjection"], RequiredPropertyIdInjection);	
		var obj:RequiredPropertyIdInjection 
				= getAndCheckObject(context, "requiredPropertyIdInjection", RequiredPropertyIdInjection) as RequiredPropertyIdInjection;
		checkDependency(context, obj.dependency);		
	}
	
	public function testPropertyIdInjectionWithMissingReqDep () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["missingPropertyIdInjection"], MissingPropertyIdInjection);
		try {
			context.getObject("missingPropertyIdInjection");		
		}
		catch (e:ContextError) {
			trace(e.getStackTrace());
			return;
		}
		fail("Expected ContextError for missing dependency");		
	}	
	
	public function testPropertyIdInjectionWithMissingOptDep () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["optionalPropertyIdInjection"], OptionalPropertyIdInjection);	
		var obj:OptionalPropertyIdInjection 
				= getAndCheckObject(context, "optionalPropertyIdInjection", OptionalPropertyIdInjection) as OptionalPropertyIdInjection;
		assertNull("Expected optional dependency to be missing", obj.dependency);	
		assertEquals("Expected default value", "foo", obj.valueWithDefault);		
	}	
	
	public function testMethodInjection () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["requiredMethodInjection"], RequiredMethodInjection);	
		var obj:RequiredMethodInjection 
				= getAndCheckObject(context, "requiredMethodInjection", RequiredMethodInjection) as RequiredMethodInjection;
		checkDependency(context, obj.dependency);		
	}	
	
	public function testMethodInjectionWithMissingReqDep () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["missingMethodInjection"], MissingMethodInjection);
		try {
			context.getObject("missingMethodInjection");		
		}
		catch (e:ContextError) {
			trace(e.getStackTrace());
			return;
		}
		fail("Expected ContextError for missing dependency");		
	}
	
	public function testMethodInjectionWithMissingOptDep () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["injectedDependency"], InjectedDependency);	
		checkObjectIds(context, ["optionalMethodInjection"], OptionalMethodInjection);	
		var obj:OptionalMethodInjection 
				= getAndCheckObject(context, "optionalMethodInjection", OptionalMethodInjection) as OptionalMethodInjection;
		assertNull("Expected optional dependency to be missing", obj.dependency);		
	}	
	
	public function testArrayInjection () : void {
		var context:Context = ActionScriptContextBuilder.build(InjectTestContainer);
		checkState(context);
		checkObjectIds(context, ["arrayPropertyInjection"], ArrayPropertyInjection);	
		checkObjectIds(context, ["date1", "date2", "date3"], Date);	
		var obj:ArrayPropertyInjection 
				= getAndCheckObject(context, "arrayPropertyInjection", ArrayPropertyInjection) as ArrayPropertyInjection;
		var deps:Array = obj.dependencies;
		assertEquals("Unexpected number of injected dependencies", 3, deps.length);
		for each (var dep:Object in deps) {
			assertTrue("Unexpected type of dependency", (dep is Date));
		}
	}

	
	private function checkDependency (context:Context, dep:InjectedDependency) : void {
		assertNotNull("Missing dependency", dep);
		var depFromContainer:InjectedDependency	
				= getAndCheckObject(context, "injectedDependency", InjectedDependency) as InjectedDependency;
		assertEquals("Expected singleton dependency", depFromContainer, dep);
	}
	
	
}
}

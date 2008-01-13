package org.spicefactory.parsley.test.mvc {
	
import org.spicefactory.parsley.mvc.ActionInterceptor;
import org.spicefactory.parsley.mvc.ActionProcessor;

public class MockInterceptor implements ActionInterceptor {
	
	
	private var _executionCount:uint = 0;
	
	
	public function intercept (processor:ActionProcessor) : void {
		_executionCount++;
		if (processor.event is MockEvent) {
			processor.proceed();
		}
	}
	
	public function get executionCount () : uint {
		return _executionCount;
	}

		
}

}
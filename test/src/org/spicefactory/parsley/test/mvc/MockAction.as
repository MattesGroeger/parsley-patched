package org.spicefactory.parsley.test.mvc {
	
import org.spicefactory.parsley.mvc.Action;
import org.spicefactory.parsley.mvc.ApplicationEvent;

public class MockAction implements Action {
	
	
	private var _executionCount:uint = 0;
	private var _delegateExecutionCount:uint = 0;
	

	
	function MockAction () {
		
	}
	
	
	public function execute (event:ApplicationEvent) : void {
		_executionCount++;
	}
	
	public function delegatedExecute (event:ApplicationEvent) : void {
		_delegateExecutionCount++;
	}
	
	public function get executionCount () : uint {
		return _executionCount;
	}
	
	public function get delegateExecutionCount () : uint {
		return _delegateExecutionCount;
	}

		
}

}
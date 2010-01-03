package org.spicefactory.parsley.core.command.task {
import org.spicefactory.lib.task.ResultTask;

/**
 * @author Jens Halm
 */
public class MockResultTask extends ResultTask {
	

	private var _result:*;


	function MockResultTask (result:*) {
		_result = result;		
	}
	
	
	public function finishWithResult () : void {
		setResult(_result);
	}
	
	public function finishWithError () : void {
		error(_result);
	}
	
	
	
}
}

package org.spicefactory.parsley.core.command.task {
import org.spicefactory.lib.task.ResultTask;

/**
 * @author Jens Halm
 */
public class MockResultTask extends ResultTask {
	

	private var _result:*;
	private var synchronous:Boolean;


	function MockResultTask (result:*, synchronous:Boolean = false, restartable:Boolean = false) {
		_result = result;
		this.synchronous = synchronous;
		setRestartable(restartable);		
	}
	
	
	protected override function doStart () : void {
		if (synchronous) {
			finishWithResult();
		}
	}

	
	public function finishWithResult () : void {
		setResult(_result);
	}
	
	public function finishWithError () : void {
		error(_result);
	}
	
	
	
}
}

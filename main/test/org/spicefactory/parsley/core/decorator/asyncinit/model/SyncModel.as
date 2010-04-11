package org.spicefactory.parsley.core.decorator.asyncinit.model {

/**
 * @author Jens Halm
 */
public class SyncModel {
	
	
	public static var instanceCount:int = 0;
	
	public static function reset () : void {
		instanceCount = 0;
	}
	
	function SyncModel () {
		instanceCount++;
	}
	
	
}
}

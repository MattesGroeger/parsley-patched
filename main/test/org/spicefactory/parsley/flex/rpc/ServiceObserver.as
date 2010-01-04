package org.spicefactory.parsley.flex.rpc {
	import mx.collections.ArrayCollection;
import mx.rpc.events.ResultEvent;

/**
 * @author Jens Halm
 */
public class ServiceObserver {
	
	
	public var response:ResultEvent;
	public var result:ArrayCollection;
	
	
	[CommandResult(selector="test1")]
	public function observeWithEventParam (response:ResultEvent) : void {
		this.response = response;
	}

	[CommandResult(selector="test1")]
	public function observeWithResultParam (result:ArrayCollection) : void {
		this.result = result;
	}
	
	
}
}

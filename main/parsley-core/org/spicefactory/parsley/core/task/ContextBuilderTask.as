package org.spicefactory.parsley.core.task {
import org.spicefactory.parsley.core.events.ContextEvent;
import org.spicefactory.lib.errors.AbstractMethodError;
import org.spicefactory.lib.task.Task;
import org.spicefactory.parsley.core.Context;

import flash.system.ApplicationDomain;

/**
 * @author Jens Halm
 */
public class ContextBuilderTask extends Task {
	
	
	private var _context:Context;
	private var parentContext:Context;
	private var domain:ApplicationDomain;


	function ContextBuilderTask (parent:Context = null, domain:ApplicationDomain = null) {
		this.parentContext = parent;
		this.domain = domain;
	}
	
	
	public function get result () : Context {
		return _context;
	}
	
	
	protected override function doStart () : void {
		var context:Context = build(parentContext, domain);
		if (context.initialized) {
			setResult(context);
		}
		else {
			context.addEventListener(ContextEvent.INITIALIZED, contextInitialized);
		}
	}
	
	private function contextInitialized (event:ContextEvent) : void {
		setResult(event.target as Context);
	}
	
	protected function setResult (context:Context) : void {
		_context = context;
		complete();
	}
 
	
	protected function build (parent:Context = null, domain:ApplicationDomain = null) : Context {
		throw new AbstractMethodError();
	}
	
	
}
}

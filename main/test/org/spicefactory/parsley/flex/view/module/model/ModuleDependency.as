package org.spicefactory.parsley.flex.view.module.model {

/**
 * @author Jens Halm
 */
public class ModuleDependency {
	
	
	function ModuleDependency () {
		trace("ModuleDependency constr");
	}
	
	[PostConstruct]
	public function init () : void {
		trace("++++ PostConstruct");
	}
	
	[PreDestroy]
	public function destroy () : void {
		trace("++++ PreDestroy");
	}
	
	
}
}

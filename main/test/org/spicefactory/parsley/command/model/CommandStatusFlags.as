package org.spicefactory.parsley.command.model {

/**
 * @author Jens Halm
 */
public class CommandStatusFlags {
	
	
	private var _flag1and2:Boolean;

	private var _flag1:Boolean;

	private var _flag2:Boolean;
	
	// Using getter/setter here so that we can override them in subclasses
	
	public function get flag1and2 ():Boolean {
		return _flag1and2;
	}
	
	public function set flag1and2 (flag1and2:Boolean):void {
		_flag1and2 = flag1and2;
	}
	
	public function get flag1 ():Boolean {
		return _flag1;
	}
	
	public function set flag1 (flag1:Boolean):void {
		_flag1 = flag1;
	}
	
	public function get flag2 ():Boolean {
		return _flag2;
	}
	
	public function set flag2 (flag2:Boolean):void {
		_flag2 = flag2;
	}
	
	
}
}

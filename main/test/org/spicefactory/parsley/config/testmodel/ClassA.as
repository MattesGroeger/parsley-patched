package org.spicefactory.parsley.config.testmodel {

import flash.geom.Rectangle;

import org.spicefactory.lib.util.collection.List;
import org.spicefactory.parsley.context.ApplicationContext;
	
	
public class ClassA {
	
	
	private var _booleanProp:Boolean;
	private var _stringProp:String;
	private var _uintProp:uint;
	private var _intProp:int;
	private var _numberProp:Number;
	private var _dateProp:Date;
	private var _classProp:Class;
	private var _arrayProp:Array;
	private var _listProp:List;
	private var _refProp:ClassB;
	private var _ref2Prop:ClassE;
	private var _contextProp:ApplicationContext;
	private var _nullProp:String = "initialValue";
	private var _rectProp:Rectangle;
	
	private var _testMethodCalled:Boolean = false;
	private static var _staticTestMethodCalled:Boolean = false;
	private var _methodArgs:Array = new Array();
	
	private static var _instanceCount:uint = 0;
	
	private static var _staticProp:String;
	
	
	function ClassA () {
		_instanceCount++;
	}
	
	
	public static function getInstance () : ClassA {
		// no need for singleton logic for this test
		return new ClassA();
	}
	
	public function get nullProp () : String {
		return _nullProp;
	}
	
	public function set nullProp (value:String) : void {
		_nullProp = value;
	}
	
	public function get booleanProp () : Boolean {
		return _booleanProp;
	}
	
	public function set booleanProp (value:Boolean) : void {
		_booleanProp = value;
	}
		
	public function get stringProp () : String {
		return _stringProp;
	}
	
	public function set stringProp (value:String) : void {
		_stringProp = value;
	}
	
	public function get uintProp () : uint {
		return _uintProp;
	}
	
	public function set uintProp (value:uint) : void {
		_uintProp = value;
	}
	
	public function get intProp () : int {
		return _intProp;
	}
	
	public function set intProp (value:int) : void {
		_intProp = value;
	}
	
	public function get numberProp () : Number {
		return _numberProp;
	}
	
	public function set numberProp (value:Number) : void {
		_numberProp = value;
	}
	
	public function get dateProp () : Date {
		return _dateProp;
	}
	
	public function set dateProp (value:Date) : void {
		_dateProp = value;
	}
	
	public function get classProp () : Class {
		return _classProp;
	}
	
	public function set classProp (value:Class) : void {
		_classProp = value;
	}
	
	public function get arrayProp () : Array {
		return _arrayProp;
	}
	
	public function set arrayProp (value:Array) : void {
		_arrayProp = value;
	}
	
	public function get listProp () : List {
		return _listProp;
	}
	
	public function set listProp (value:List) : void {
		_listProp = value;
	}
	
	public function get refProp () : ClassB {
		return _refProp;
	}
	
	public function set refProp (value:ClassB) : void {
		_refProp = value;
	}
	
	public function get ref2Prop () : ClassE {
		return _ref2Prop;
	}
	
	public function set ref2Prop (value:ClassE) : void {
		_ref2Prop = value;
	}
	
	public function get contextProp () : ApplicationContext {
		return _contextProp;
	}
	
	public function set contextProp (value:ApplicationContext) : void {
		_contextProp = value;
	}
	
	public function get rectProp () : Rectangle {
		return _rectProp;
	}
	
	public function set rectProp (value:Rectangle) : void {
		_rectProp = value;
	}
	
	public static function get staticProp () : String {
		return _staticProp;
	}
	
	public static function set staticProp (value:String) : void {
		_staticProp = value;
	}
	
	public static function get instanceCount () : uint {
		return _instanceCount;
	}
	
	public static function clearInstanceCount () : void {
		_instanceCount = 0;
	}
	
	
	public function testMethod () : void {
		_testMethodCalled = true;
	}
	
	public function testMethodWithArg (arg:*) : void {
		_methodArgs.push(arg);
	}
	
	public static function staticTestMethod () : void {
		_staticTestMethodCalled = true;
	}
	
	public function testMethodWithArgs (arr:Array, num:uint, flag:Boolean) : void {
		_methodArgs = arguments;
	}
	
	public function get testMethodCalled () : Boolean {
		return _testMethodCalled;
	}
	
	public static function get staticTestMethodCalled () : Boolean {
		return _staticTestMethodCalled;
	}
	
	public function get testMethodArgs () : Array { 
		return _methodArgs;
	}
	
	
}

}


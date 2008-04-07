package org.spicefactory.parsley.config.testmodel {
	
public class Book {
	
	private var _title:String;
	private var _author:String;
	private var _price:Number;
	
	public function get title () : String {
		return _title;
	}
	
	public function set title (value:String) : void {
		_title = value;
	}
	
	public function get author () : String {
		return _author;
	}
	
	public function set author (value:String) : void {
		_author = value;
	}
	
	public function get price () : Number {
		return _price;
	}
	
	public function set price (value:Number) : void {
		_price = value;
	}
	
}

}
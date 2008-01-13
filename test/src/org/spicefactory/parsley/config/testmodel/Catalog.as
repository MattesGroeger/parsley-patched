package org.spicefactory.parsley.config.testmodel {
	
public class Catalog {
	
	private var books:Array = new Array();
	
	public function addBook (book:Book) : void {
		books.push(book);
	}	
	
	public function getAllBooks () : Array {
		return books.concat();
	}
	
}

}
/**
 * @author		keita (keita.kun@gmail.com)
 * @svn			http://code.hellokeita.in/public
 * @url			http://labs.hellokeita.com/
 * 
 */
package br.hellokeita.utils{
	
	public class StringUtils{
		
		private static const LTrimExp:RegExp = /^(\s|\n|\r|\t|\v)*/m;
		private static const RTrimExp:RegExp = /(\s|\n|\r|\t|\v)*$/;
		
		public function StringUtils(){
			trace("It's a static class. You should not instantiate this class.");
		}
		
		public static function rtrim(v:String):String {
			return v.replace(LTrimExp, "");
		}
		public static function ltrim(v:String):String {
			return v.replace(RTrimExp, "");
		}
		public static function trim(v:String):String {
			return ltrim(rtrim(v));
		}
	}
}
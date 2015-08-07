package  
{
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author qzd
	 */
	public class myButton extends MovieClip
	{
		
		public function myButton(name:String) 
		{
			this.bName.text = name;
			this.bName.mouseEnabled = false;
			this.buttonMode = true;
		}
		public function changeName(name:String) {
			this.bName.text = name;
		}
	}

}
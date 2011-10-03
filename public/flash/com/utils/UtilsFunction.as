package com.app.utils
{
	import com.hurlant.util.Base64;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import ru.inspirit.encoders.png.PNGEncoder;

	public class UtilsFunction
	{
		public function UtilsFunction()
		{
		}
		
		public static function EncodeBitmap( value:BitmapData , compression:Number	=	0 )
		{
			var jpgStream:ByteArray = ImageToByteArray( value, compression );
			var b64 = Base64.encodeByteArray(jpgStream);
			return b64.toString();
		}
		public static function ImageToByteArray( value:BitmapData , compression:Number	=	0 )
		{
			return PNGEncoder.encode( value, false, compression );
		}
	}
}
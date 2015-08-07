package com.adobe.crypto
{
    import com.adobe.utils.*;
    import flash.utils.*;
    import mx.utils.*;

    public class SHA1 extends Object
    {
        public static var digest:ByteArray;

        public function SHA1()
        {
            return;
        }// end function

        public static function hash(param1:String) : String
        {
            var _loc_2:* = createBlocksFromString(param1);
            var _loc_3:* = hashBlocks(_loc_2);
            return IntUtil.toHex(_loc_3.readInt(), true);
        }// end function

        public static function hashBytes(param1:ByteArray) : String
        {
            var _loc_2:* = SHA1.createBlocksFromByteArray(param1);
            var _loc_3:* = hashBlocks(_loc_2);
            return IntUtil.toHex(_loc_3.readInt(), true);
        }// end function

        public static function hashToBase64(param1:String) : String
        {
            var _loc_7:uint = 0;
            var _loc_2:* = SHA1.createBlocksFromString(param1);
            var _loc_3:* = hashBlocks(_loc_2);
            var _loc_4:String = "";
            _loc_3.position = 0;
            var _loc_5:int = 0;
            while (_loc_5 < _loc_3.length)
            {
                
                _loc_7 = _loc_3.readUnsignedByte();
                _loc_4 = _loc_4 + String.fromCharCode(_loc_7);
                _loc_5++;
            }
            var _loc_6:* = new Base64Encoder();
            new Base64Encoder().encode(_loc_4);
            return _loc_6.flush();
        }// end function

        private static function hashBlocks(param1:Array) : ByteArray
        {
            var _loc_9:int = 0;
            var _loc_12:int = 0;
            var _loc_13:int = 0;
            var _loc_14:int = 0;
            var _loc_15:int = 0;
            var _loc_16:int = 0;
            var _loc_17:int = 0;
            var _loc_2:int = 1732584193;
            var _loc_3:int = 4023233417;
            var _loc_4:int = 2562383102;
            var _loc_5:int = 271733878;
            var _loc_6:int = 3285377520;
            var _loc_7:* = param1.length;
            var _loc_8:* = new Array(80);
            var _loc_10:int = 0;
            while (_loc_10 < _loc_7)
            {
                
                _loc_12 = _loc_2;
                _loc_13 = _loc_3;
                _loc_14 = _loc_4;
                _loc_15 = _loc_5;
                _loc_16 = _loc_6;
                _loc_17 = 0;
                while (_loc_17 < 20)
                {
                    
                    if (_loc_17 < 16)
                    {
                        _loc_8[_loc_17] = param1[_loc_10 + _loc_17];
                    }
                    else
                    {
                        _loc_9 = _loc_8[_loc_17 - 3] ^ _loc_8[_loc_17 - 8] ^ _loc_8[_loc_17 - 14] ^ _loc_8[_loc_17 - 16];
                        _loc_8[_loc_17] = _loc_9 << 1 | _loc_9 >>> 31;
                    }
                    _loc_9 = (_loc_12 << 5 | _loc_12 >>> 27) + (_loc_13 & _loc_14 | ~_loc_13 & _loc_15) + _loc_16 + int(_loc_8[_loc_17]) + 1518500249;
                    _loc_16 = _loc_15;
                    _loc_15 = _loc_14;
                    _loc_14 = _loc_13 << 30 | _loc_13 >>> 2;
                    _loc_13 = _loc_12;
                    _loc_12 = _loc_9;
                    _loc_17++;
                }
                while (_loc_17 < 40)
                {
                    
                    _loc_9 = _loc_8[_loc_17 - 3] ^ _loc_8[_loc_17 - 8] ^ _loc_8[_loc_17 - 14] ^ _loc_8[_loc_17 - 16];
                    _loc_8[_loc_17] = _loc_9 << 1 | _loc_9 >>> 31;
                    _loc_9 = (_loc_12 << 5 | _loc_12 >>> 27) + (_loc_13 ^ _loc_14 ^ _loc_15) + _loc_16 + int(_loc_8[_loc_17]) + 1859775393;
                    _loc_16 = _loc_15;
                    _loc_15 = _loc_14;
                    _loc_14 = _loc_13 << 30 | _loc_13 >>> 2;
                    _loc_13 = _loc_12;
                    _loc_12 = _loc_9;
                    _loc_17++;
                }
                while (_loc_17 < 60)
                {
                    
                    _loc_9 = _loc_8[_loc_17 - 3] ^ _loc_8[_loc_17 - 8] ^ _loc_8[_loc_17 - 14] ^ _loc_8[_loc_17 - 16];
                    _loc_8[_loc_17] = _loc_9 << 1 | _loc_9 >>> 31;
                    _loc_9 = (_loc_12 << 5 | _loc_12 >>> 27) + (_loc_13 & _loc_14 | _loc_13 & _loc_15 | _loc_14 & _loc_15) + _loc_16 + int(_loc_8[_loc_17]) + 2400959708;
                    _loc_16 = _loc_15;
                    _loc_15 = _loc_14;
                    _loc_14 = _loc_13 << 30 | _loc_13 >>> 2;
                    _loc_13 = _loc_12;
                    _loc_12 = _loc_9;
                    _loc_17++;
                }
                while (_loc_17 < 80)
                {
                    
                    _loc_9 = _loc_8[_loc_17 - 3] ^ _loc_8[_loc_17 - 8] ^ _loc_8[_loc_17 - 14] ^ _loc_8[_loc_17 - 16];
                    _loc_8[_loc_17] = _loc_9 << 1 | _loc_9 >>> 31;
                    _loc_9 = (_loc_12 << 5 | _loc_12 >>> 27) + (_loc_13 ^ _loc_14 ^ _loc_15) + _loc_16 + int(_loc_8[_loc_17]) + 3395469782;
                    _loc_16 = _loc_15;
                    _loc_15 = _loc_14;
                    _loc_14 = _loc_13 << 30 | _loc_13 >>> 2;
                    _loc_13 = _loc_12;
                    _loc_12 = _loc_9;
                    _loc_17++;
                }
                _loc_2 = _loc_2 + _loc_12;
                _loc_3 = _loc_3 + _loc_13;
                _loc_4 = _loc_4 + _loc_14;
                _loc_5 = _loc_5 + _loc_15;
                _loc_6 = _loc_6 + _loc_16;
                _loc_10 = _loc_10 + 16;
            }
            var _loc_11:* = new ByteArray();
            new ByteArray().writeInt(_loc_2);
            _loc_11.writeInt(_loc_3);
            _loc_11.writeInt(_loc_4);
            _loc_11.writeInt(_loc_5);
            _loc_11.writeInt(_loc_6);
            _loc_11.position = 0;
            digest = new ByteArray();
            digest.writeBytes(_loc_11);
            digest.position = 0;
            return _loc_11;
        }// end function

        private static function createBlocksFromByteArray(param1:ByteArray) : Array
        {
            var _loc_2:* = param1.position;
            param1.position = 0;
            var _loc_3:* = new Array();
            var _loc_4:* = param1.length * 8;
            var _loc_5:int = 255;
            var _loc_6:int = 0;
            while (_loc_6 < _loc_4)
            {
                
                _loc_3[_loc_6 >> 5] = _loc_3[_loc_6 >> 5] | (param1.readByte() & _loc_5) << 24 - _loc_6 % 32;
                _loc_6 = _loc_6 + 8;
            }
            _loc_3[_loc_4 >> 5] = _loc_3[_loc_4 >> 5] | 128 << 24 - _loc_4 % 32;
            _loc_3[(_loc_4 + 64 >> 9 << 4) + 15] = _loc_4;
            param1.position = _loc_2;
            return _loc_3;
        }// end function

        private static function createBlocksFromString(param1:String) : Array
        {
            var _loc_2:* = new Array();
            var _loc_3:* = param1.length * 8;
            var _loc_4:int = 255;
            var _loc_5:int = 0;
            while (_loc_5 < _loc_3)
            {
                
                _loc_2[_loc_5 >> 5] = _loc_2[_loc_5 >> 5] | (param1.charCodeAt(_loc_5 / 8) & _loc_4) << 24 - _loc_5 % 32;
                _loc_5 = _loc_5 + 8;
            }
            _loc_2[_loc_3 >> 5] = _loc_2[_loc_3 >> 5] | 128 << 24 - _loc_3 % 32;
            _loc_2[(_loc_3 + 64 >> 9 << 4) + 15] = _loc_3;
            return _loc_2;
        }// end function

    }
}

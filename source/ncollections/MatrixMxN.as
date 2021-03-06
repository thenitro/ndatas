package ncollections {
    import flash.utils.Dictionary;

    import npooling.IReusable;
    import npooling.Pool;

    public class MatrixMxN implements IReusable {
		protected static var _pool:Pool = Pool.getInstance();

        private var _disposed:Boolean;

		private var _rows:Dictionary;

        private var _minX:int;
        private var _minY:int;

		private var _maxX:int;
		private var _maxY:int;
		
		private var _count:int;
		
		private var _items:Set;
		
		public function MatrixMxN() {
			_count = 0;
			_rows  = new Dictionary();
			_items = Set.EMPTY;
		};
		
		public static function get EMPTY():MatrixMxN {
			var result:MatrixMxN = _pool.get(MatrixMxN) as MatrixMxN;
			
			if (!result) {
				_pool.allocate(MatrixMxN, 1);
				result = new MatrixMxN();
			}
			
			return result;
		};

        public static function fromArray(pInput:Array):MatrixMxN {
            var result:MatrixMxN = _pool.get(MatrixMxN) as MatrixMxN;

            for (var j:int = 0; j < pInput.length; j++) {
                var row:Array = pInput[j] as Array;

                for (var i:int = 0; i < row.length; i++) {
                    result.add(i, j, row[i]);
                }
            }

            return result;
        };
		
		public function get minX():int {
			return _minX;
		};
		
		public function get minY():int {
			return _minY;
		};

		public function get maxX():int {
			return _maxX;
		};

		public function get maxY():int {
			return _maxY;
		};

		public function get count():int {
			return _count;
		};
		
		public function get reflection():Class {
			return MatrixMxN;
		};

        public function get disposed():Boolean {
            return _disposed;
        };

		public function get items():Set {
			return _items;
		};
		
		public function add(pX:int, pY:int, pObject:Object):Object {
			var cols:Dictionary = takeCol(pX);
				cols[pY] = pObject;

            if (pY <= _minY) {
                _minY = pY;
            }

			if (pY >= _maxY) {
				_maxY = pY + 1;
			}
			
			_count++;
			
			_items.add(pObject);
			
			return pObject;
		};
		
		public function take(pX:int, pY:int):Object {
            if (pX < minX || pY < minY || pX > maxX || pY > maxY) {
                return null;
            }

			var cols:Dictionary = _rows[pX] as Dictionary;
			if (!cols) {
				return null;
			}
			
			return cols[pY] as Object;
		};

        public function takeByPattern(pIndexX:int, pIndexY:int,
                                      pPattern:Array):Array {
            var medianaX:int = pPattern[0].length / 2;
            var medianaY:int = pPattern.length / 2;

            var patternIndexI:int;
            var patternIndexJ:int;

            var matrixIndexI:int;
            var matrixIndexJ:int;

            var result:Array = [];

            for (patternIndexJ = 0, matrixIndexJ = pIndexY - medianaY; patternIndexJ < pPattern.length; patternIndexJ++, matrixIndexJ++) {
                var row:Array = pPattern[patternIndexJ] as Array;

                for (patternIndexI = 0, matrixIndexI = pIndexX - medianaX; patternIndexI < row.length; patternIndexI++, matrixIndexI++) {
                    if (!take(matrixIndexI, matrixIndexJ) || !pPattern[patternIndexJ][patternIndexI]) {
                        continue;
                    }

                    result.push(take(matrixIndexI, matrixIndexJ));
                }
            }

            return result;
        };
		
		public function remove(pX:int, pY:int):void {
			var cols:Dictionary = _rows[pX];
			
			if (!cols) {
				return;
			}
			
			_count--;
			
			_items.remove(cols[pY]);
			
			delete cols[pY];
		};
		
		public function takeCol(pX:int):Dictionary {
			var cols:Dictionary = _rows[pX];
			
			if (!cols) {
				cols = new Dictionary();
				_rows[pX] = cols;
			}

            if (pX <= _minX) {
                _minX = pX;
            }
			
			if (pX >= _maxX) {
				_maxX = pX + 1;
			}
			
			return cols;
		};

       public function calcColItems(pY:int):int {
           var result:int = 0;

           for (var i:int = minX; i < maxX; i++) {
               if (take(i, pY)) {
                   result++;
               }
           }

           return result;
       };

        public function removeLastCol():void {
            for (var i:int = minX; i < maxX; i++) {
                remove(i, _maxY - 1);
            }

            _maxY--;
        };
		
		public function swap(pObjectAX:int, pObjectAY:int, 
							 pObjectBX:int, pObjectBY:int):void {
			var objectA:Object = take(pObjectAX, pObjectAY);
			var objectB:Object = take(pObjectBX, pObjectBY);
			
			add(pObjectAX, pObjectAY, objectB);
			add(pObjectBX, pObjectBY, objectA);
		};
		
		public function clean():void {
            _minY = 0;
            _minX = 0;

			_maxX = 0;
			_maxY = 0;
			
			_count = 0;
			
			_rows = new Dictionary();
		};
		
		public function clone():MatrixMxN {
			var result:MatrixMxN = _pool.get(MatrixMxN) as MatrixMxN;
			
			if (!result) {
				result = new MatrixMxN();
			}
			
			for (var i:int = 0; i < maxX; i++) {
				for (var j:int = 0; j < maxY; j++) {
					if (take(i, j)) {
						result.add(i, j, take(i, j).clone());
					}
				}
			}
			
			return result;
		};
		
		public function poolPrepare():void {
			clean();
		};
		
		public function dispose():void {
			clean();

            _disposed = true;
		};
	}
}
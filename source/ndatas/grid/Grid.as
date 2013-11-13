package ndatas.grid {
	import ndatas.MatrixMxN;
	
	public class Grid extends MatrixMxN {
		
		public function Grid() {
			super();
		};
		
		override public function get reflection():Class {
			return Grid;
		};
		
		override public function add(pX:uint, pY:uint, pObject:Object):Object {
			if (pObject) {
				pObject.updateIndex(pX, pY);
			}
			
			return super.add(pX, pY, pObject);
		};
		
		override public function clone():MatrixMxN {
			var grid:Grid = _pool.get(Grid) as Grid;
			
			if (!grid) {
				grid = new Grid();
			}
			
			for (var i:uint = 0; i < sizeX; i++) {
				for (var j:uint = 0; j < sizeY; j++) {
					if (take(i, j)) {
						grid.add(i, j, take(i, j).clone());
					}
				}
			}
			
			return grid;
		};
	}
}
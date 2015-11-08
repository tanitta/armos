module armos.graphics.style;
import armos.graphics;

class Style {
	armos.graphics.Color color;
	armos.graphics.Color backgroundColor;
	bool isFill = true;
	// blendingMode;
	// lineWidth;
	
	this(){
		color = new armos.graphics.Color(255, 255, 255, 255);
		backgroundColor = new armos.graphics.Color(30, 30, 30, 255);
	}
}

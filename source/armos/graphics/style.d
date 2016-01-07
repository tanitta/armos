module armos.graphics.style;
import armos.graphics;
import armos.types;

/++
++/
class Style {
	armos.types.Color color;
	armos.types.Color backgroundColor;
	armos.graphics.BlendMode blendMode;
	float lineWidth = 1.0;
	bool isSmoothing = true;
	bool isFill = true;
	// blendingMode;
	// lineWidth;
	
	this(){
		color = armos.types.Color(255, 255, 255, 255);
		backgroundColor = armos.types.Color(30, 30, 30, 255);
	}
}

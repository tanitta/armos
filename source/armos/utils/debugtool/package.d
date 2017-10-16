module armos.utils.debugtool;
import armos.graphics;

///
void drawGridPlane(
        in float stepSize, in int numberOfSteps,
        in bool labels=false 
        ){
    for (int i = -numberOfSteps; i <= numberOfSteps; i++) {
        drawLine( -stepSize*numberOfSteps, 0.0,  i*stepSize,              stepSize*numberOfSteps, 0.0, i*stepSize             );
        drawLine( i*stepSize,              0.0,  -stepSize*numberOfSteps, i*stepSize            , 0.0, stepSize*numberOfSteps );
    }
}

///
void drawAxis(in float size){
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: use material");
    // pushStyle;{
        // lineWidth = 2.0;
        // color(1, 0, 0);
        drawLine(-size*0.5, 0.0, 0.0, size, 0.0,  0.0);
        // color(0, 1, 0);
        drawLine(0.0, -size*0.5, 0.0, 0.0,  size, 0.0);
        // color(0, 0, 1);
        drawLine(0.0, 0.0, -size*0.5, 0.0,  0.0,  size);
    // }popStyle;
}

///
void drawGrid(
        in float stepSize, in int numberOfSteps,
        in bool labels=false, in bool x=true, in bool y=true, in bool z=true
        ){
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: use material");
    // pushStyle;{
        pushMatrix;{
            rotate(90.0, 0, 0, 1);
            if(x){
                // color(1, 0, 0);
                drawGridPlane(stepSize, numberOfSteps);
            }
            rotate(-90.0, 0, 0, 1);
            if(y){
                // color(0, 1, 0);
                drawGridPlane(stepSize, numberOfSteps);
            }
            rotate(90.0, 1, 0, 0);
            if(z){
                // color(0, 0, 1);
                drawGridPlane(stepSize, numberOfSteps);
            }
        }popMatrix;
    // }popStyle;
}

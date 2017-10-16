module armos.app.appcollection;

import armos.app.application;
import armos.graphics.scene;
import armos.app.window;
import armos.app.windowconfig;

///
struct ApplicationBundle {
    Window window;
    Application application;
    Scene scene;
}//struct ApplicationBundle

///
alias AppCollection = ApplicationBundle[Window];

///
auto add(ref AppCollection collection,
         Window window, 
         Application app,
         Scene scene
 ){
    collection[window] = ApplicationBundle(window, app, scene);
    return collection;
}

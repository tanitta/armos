module armos.app.appcollection;

import armos.app.application;
import armos.app.window;
import armos.app.windowconfig;

///
alias AppCollection = Application[Window];

///
auto add(ref AppCollection collection, Application app, Window window){
    collection[window] = app;
    return collection;
}

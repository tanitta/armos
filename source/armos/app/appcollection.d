module armos.app.appcollection;

import armos.app.baseapp;
import armos.app.window;
import armos.app.windowconfig;

///
alias AppCollection = BaseApp[Window];

///
auto add(ref AppCollection collection, BaseApp app, Window window){
    collection[window] = app;
    return collection;
}

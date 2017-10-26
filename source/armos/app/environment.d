module armos.app.environment;

import armos.app.application;
import armos.app.window;
import armos.graphics.gl.context;

///
interface Environment {
    public{
        ///
        Application application();

        ///
        Window window();

        ///
        Context context();

        ///
        Environment build()
        out(e){
            assert(this.application);
            assert(this.window);
            assert(this.context);
        };
    }//public
}//interface Environment

auto add(ref Environment[Window] collection,
             Environment env
){
    collection[env.window] = env;
    return collection;
}

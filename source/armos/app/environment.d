module armos.app.environment;

import armos.app.application;
import armos.app.window;
import armos.graphics.gl.context;
import armos.graphics.renderer;

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
        Renderer renderer();

        ///
        Environment build()
        out(e){
            assert(this.application);
            assert(this.window);
            assert(this.context);
            assert(this.renderer);
        };
    }//public
}//interface Environment

auto add(ref Environment[Window] collection,
             Environment env
){
    collection[env.window] = env;
    return collection;
}

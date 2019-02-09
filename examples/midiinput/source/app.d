static import ar = armos;

class MainApp : ar.app.BaseApp{
    override void setup(){
        _stream = new ar.communication.MidiStream();
    }

    override void update(){
        import std.stdio;
        auto messages = _stream.popMessages;
        if(messages.length != 0){
            messages.writeln;
        }
    }

    ar.communication.MidiStream _stream;
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new MainApp);
    }
}

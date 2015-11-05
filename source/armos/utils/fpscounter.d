module armos.utils.fpscounter;
import core.time;
import core.thread;
class FpsCounter {
	private double targetFps = 60.0;
	private double currentFps = 60.0;
	private ulong  nFrameCount = 0;
	private int targetTime = 0;
	private MonoTime timer;
	this(double targetFps = 60){
		timer = MonoTime.currTime;
		this.targetFps = targetFps;
		this.currentFps= targetFps;
		targetTime = cast(int)(1.0/targetFps*10000000);
	}

	double getTargetFps(){
		return targetFps;
	}
	double getCurrentFps(){
		return currentFps;
	}

	void newFrame(){
		timer = MonoTime.currTime;
		nFrameCount++;
	}
	
	ulong getNumFrames(){return nFrameCount;};

	void adjust(){
		MonoTime after = MonoTime.currTime;
		auto def = after - timer;
		if( def.fracSec.hnsecs < targetTime){
			Thread.sleep( dur!("hnsecs")( targetTime - def.fracSec.hnsecs ) );
		}
		MonoTime after2 = MonoTime.currTime;
		auto def2 = after2 - timer;
		currentFps = 1.0/cast(double)(def2.fracSec.hnsecs)*10000000;
	}

}
unittest{
	import std.stdio;
	auto fps = new FpsCounter(30);
	MonoTime before = MonoTime.currTime;
	
	// Thread.sleep( dur!("hnsecs")(110000000) );
	// for (int i = 0; i < 10; i++) {
	// 	writeln(fps.getCurrentFps());
	//	
	// 	fps.adjust();
	// 	fps.newFrame();
	// 	writeln(i);
	// }
	
	MonoTime after = MonoTime.currTime;
	Duration timeElapsed = after - before;
	writeln("time");
	writeln(timeElapsed.fracSec.hnsecs );
}


s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

~recDur = 1;

s.waitForBoot({
	Routine {
		var record, grain;
		
		//Buffer for recording/playing sound
		b = Buffer.alloc(s, 44100 * ~recDur, 1);
		
		SynthDef(\Record,{ | in=0, bufnum=0 |
			RecordBuf.ar(AudioIn.ar(in), bufnum);
		}).load(s);

		//Granularize recorded sound
		SynthDef(\Warp, { | buffer = 0, pointer =0.3 |
			var out;
			out = Warp1.ar(1, buffer, MouseX.kr(0,2), MouseY.kr(1.5, 0.5), 0.1, -1, 8, 0.15, 1.0);
			Out.ar(0, out);
		}).send(s);
		
		1.wait;
		
		"Recording...".postln;
		record = Synth(\Record, [\in, 1, \bufnum, b.bufnum]);
		
		~recDur.wait;
		
		"Recording Done!".postln;
		record.free;
		
		grain = Synth(\Warp, [\buffer, b.bufnum]);
		
	}.play;
});

//Rerecord sound
//(
//	Routine{
//		var record;
//		"Recording...".postln;
//		record = Synth(\Record, [\in, 1, \bufnum, b.bufnum]);
//		~recDur.wait;
//		"Recording Done!".postln;
//		record.free;
//	}.play;
//)
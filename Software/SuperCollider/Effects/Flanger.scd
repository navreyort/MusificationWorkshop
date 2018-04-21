s = Server.local.boot;
o = Server.local.options;
o.memSize_(32768);

~recDur = 1;

s.waitForBoot({
	Routine {
		
		SynthDef(\Flanger, { arg out=0, in=0, delay=0.1, depth=0.08, rate=0.06, fdbk=0.0, decay=0.0; 
			var input, maxdelay, maxrate, dsig, mixed, local;
			maxdelay = 0.013;
			maxrate = 10.0;
			input = In.ar(in, 1);
			local = LocalIn.ar(1);
			dsig = AllpassL.ar( // the delay (you could use AllpassC (put 0 in decay))
				input + (local * fdbk),
				maxdelay * 2,
				LFPar.kr( // very similar to SinOsc (try to replace it) - Even use LFTri
					rate * maxrate,
					0,
					depth * maxdelay,
					delay * maxdelay),
				decay);
			mixed = input + dsig;
			LocalOut.ar(mixed);
			Out.ar([out, out+1], mixed);
		}).send(s);
		
		1.wait;
		
		{Out.ar(10, AudioIn.ar(1))}.play(s, addAction:\addToHead);
		f = Synth(\Flanger, [\in, 10], addAction:\addToTail);
		
	}.play;
});

//f.set(\delay, 0.04)
//f.set(\depth, 0.04)
//f.set(\rate, 0.01)
//f.set(\fdbk, 0.08)
//f.set(\decay, 0.01)
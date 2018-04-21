s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {

		SynthDef(\FMSynth, { | out=0, freq=440, car=1, mod=1, index=3, mul=0.2, amp=0.2, dur=1 |
			var m = SinOsc.ar(freq * mod, 0, freq * index );
			var c =  SinOsc.ar((freq * car) + m, 0, mul );
			var env = EnvGen.kr(Env.triangle(dur), doneAction: 2);
			
			Out.ar(out,Pan2.ar(c*env))*amp;
		}).send(s);
		
		1.wait;
		
		loop{ |i|
			var dur = rrand(0.2,1.0);
			var freq = rrand(60,90).midicps;
			var car = rrand(0.5,4);
			var mod = rrand(1,2); 
			s.sendMsg(\s_new, \FMSynth, s.nextNodeID, 3, 1, \out, 0, \amp, 1, \dur, dur,
						\freq, freq, \car, car, \mod, mod);
			(dur*0.7).wait;
		}
		
	}.play;
});
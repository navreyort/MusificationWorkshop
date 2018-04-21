s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {

		SynthDef(\AddtiveBell, { | out=0, ampOut=0.2, dur=1 |
			var numOsc = 12;
			var osc;
			var env = EnvGen.kr(Env.triangle(dur), doneAction: 2);
			
			osc = SinOsc.ar([Rand(67,2000), Rand(67,2000)],0, numOsc.reciprocal);
			(numOsc-1).do{ |i|
				osc = osc + SinOsc.ar([Rand(67,2000),Rand(67,2000)],0, numOsc.reciprocal);
			};
			
			Out.ar(out,osc*env)*ampOut;
		}).send(s);
		
		1.wait;
		
		loop{ |i|
			var dur = rrand(7.0,10.0);
			dur.postln;
			s.sendMsg(\s_new, \AddtiveBell, s.nextNodeID, 3, 1, \out, 0, \ampOut, 1, \dur, dur);
			(dur*0.7).wait;
		}
		
	}.play;
});
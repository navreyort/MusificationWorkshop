s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

~recDur = 1;

s.waitForBoot({
	Routine {
		
		SynthDef(\KSGuitar, { arg note, pan, rand, delayTime, noiseType=1;
			var x, y, env;
			env = Env.new(#[1, 1, 0],#[2, 0.001]);
			// A simple exciter x, with some randomness.
			x = Decay.ar(Impulse.ar(0, 0, rand), 0.1+rand, WhiteNoise.ar); 
		 	x = CombL.ar(x, 0.05, note.reciprocal, delayTime, EnvGen.ar(env, doneAction:2)); 
			x = Pan2.ar(x, pan);
			Out.ar(0, LeakDC.ar(x));
		}).send(s);
		
		1.wait;
		
		loop{
			Synth(\KSGuitar, [\note, 220+(400.rand), 
					\pan, 1.0.rand2, 
					\rand, 0.1+0.1.rand, 
					\delayTime, 2+1.0.rand]);
					
	 	 	(1.0.rand + 0.1).wait;	
		};
	}.play;
});
s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		//Initialize variables and allocate synths
		SynthDef(\RandomImpulse, { | out=4, ampOut=0.2, attack=10, sustain=5, release=15, i_phase=0 |
			var env = EnvGen.kr(Env.linen(attack,sustain,release), doneAction: 2);
			Out.ar(out,
				LFPulse.ar(
					LFNoise2.kr(1,add:2*env),
					i_phase,
					LFNoise2.kr(1,add:1)*0.125+0.25
				)
			)*env*ampOut;
		}).send(s);
	
		//Wait for synth allocation
		1.wait;
		
		//Execute synths
		s.sendMsg(\s_new, \RandomImpulse, s.nextNodeID, 3, 1, \out, 0, \ampOut, 1);
	}.play;
});
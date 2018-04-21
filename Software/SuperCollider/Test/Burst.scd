s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		{  
 			var burstEnv, att = 0, dec = 0.001; //Variable declarations 
			burstEnv = EnvGen.kr(Env.perc(att, dec), gate: Impulse.kr(1)); //envelope 
 			PinkNoise.ar(burstEnv); //Noise, amp controlled by burstEnv 
		}.play 
	}.play;
});
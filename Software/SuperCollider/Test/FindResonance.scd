s = Server.local.boot;
o = Server.local.options;
o.memSize_(16384);

s.waitForBoot({
	Routine {
		{SinOsc.ar(MouseX.kr(100,5000), mul: 0.5)}.play;
	}.play;
});
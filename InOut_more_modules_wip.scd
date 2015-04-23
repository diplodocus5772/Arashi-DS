/**
* A couple of modules that I need to convert to the format of our instrument
*/

//_startServerUtilities
(
//Server.killAll;
//USE ONLY IF YOU WOULD LIKE TO OUTPUT TO GO OUT OF "_________" (not default output)
//--OTHERWISE SIMPLY EVALUATE "s.boot" to boot with default audio output
s = Server.new(\beast);
o = s.options;
//o.inDevice = "Soundflower (2ch)";
o.inDevice = "MOTU 4pre";
//o.outDevice = "MOTU 4pre";
//o.inDevice = "Built-in Microph";
o.outDevice = "Built-in Output";
o.memSize = 8192 * 4;
s.boot;
)



//****************************************************************************//
//_SynthDefs
//---------------------------------\\
(
SynthDef(\Butter,{ |freq = 30, amp = 0.95, dur = 1|
	var env, tone;
	env = Env.new([0, 0.8, 0], [dur/16, dur/16 * 15], \lin);
	env = EnvGen.ar(env, doneAction:2);
	tone = SinOsc.ar( freq * (1,3..10) * 0.95, mul:(1/5) ).sum.dup;
	tone = Clip.ar(tone, 0, 0.8);
	tone = HPF.ar(tone, freq*3);
	Out.ar(10, env * tone);
}).load(s);


SynthDef(\CombFilter,{ |frequency = 30, resonance = 1, octaves = 10, lagTime = 3|
	var in, delay, delayTime, comb;
	in = In.ar(10, 2);
	delayTime = Lag.kr(1/frequency, lagTime);
	delay = CombC.ar(in, delaytime:delayTime, decaytime:resonance) * 0.4;
	// delay = LPF.ar(delay, frequency * octaves * 10);
	comb = in + delay;
	// comb = HPF.ar(comb, frequency * 4);
	Out.ar(20, comb * 0.5);
}).load(s);

SynthDef(\Snare,{
	var env, noise;
	env = Env.new([0, 0.8, 0], [0.005, 0.01], \lin);
	env = EnvGen.ar(env, doneAction:2);
	noise = WhiteNoise.ar(0.95);
	noise = BPF.ar(noise, 1000).dup;
	Out.ar(30, noise * env);
}).load(s);

SynthDef(\Reverb,{
	var in1, in2, predelay1, predelay2, reverb1, reverb2;
	in1 = In.ar(20);
	in2 = In.ar(21);
	predelay1 = DelayN.ar(in1, 0.1, 0.048);
	predelay2 = DelayN.ar(in2, 0.1, 0.052);
	reverb1 = Mix.ar(Array.fill(7,{ CombL.ar(predelay1, 0.05, rrand(0.03, 0.05), 3) }));
	reverb2 = Mix.ar(Array.fill(7,{ CombL.ar(predelay2, 0.05, rrand(0.03, 0.05), 3) }));
	6.do({ reverb1 = AllpassN.ar(reverb1, 0.050, rrand(0.03, 0.05), 6) });
	6.do({ reverb2 = AllpassN.ar(reverb2, 0.050, rrand(0.03, 0.05), 6) });
	Out.ar(100, [reverb1, reverb2] * 0.1);
}).load(s);

SynthDef(\Delay,{
	var in, delay1, delay2, mix;
	in = In.ar(30, 2);

	delay1 = Array.fill( 12,{
		CombC.ar(in[0], 0.8, rrand(0.005, 0.1), 2)
	}).sum / 12;

	delay2 = Array.fill( 12,{
		CombC.ar(in[1], 0.8, rrand(0.005, 0.1), 2)
	}).sum / 12;

	mix = [delay1, delay2];
	Out.ar(100, mix);
}).load(s);

//_Output Module
SynthDef(\output, {
	arg amp = 1.0;
	var in0,in1,in2,in3,in4,
	mix,mix2,mix3,mix4;
	//
	in0 = In.ar(100,2); //all inputs are stereo
	in1 = In.ar(102,2);
	in2 = In.ar(104,2);
	in3 = In.ar(106,2);
	in4 = In.ar(108,2);
	//

	mix = in0;//in1+in2+in3+in4; //...etc
	Out.ar(0, mix);
	}
).load(s);

)


//****************************************************************************//
//_Passive Synths

~output=Synth.tail(1,\output);
(
~comb = Synth.before(~output,\CombFilter, [\frequency, 30]);
~delay = Synth.before(~output,\Delay);
~reverb = Synth.before(~output,\Reverb);
);


//****************************************************************************//
//_Routines
(
Synth(\Butter, [\dur, 5]);

/*~r1 = Routine({
	5.do{ |i|
		var dur = (i + 1)/2;
		Synth(\Butter, [\freq, 20 * (10000.rand/1000), \dur, 30]);
		// (dur * 1.1).wait;
	};
	// Synth(\ButteryGoodness, [\dur, 10]);
	~comb.set(\lagTime, 10, \frequency, 30);
});
);

~r1.play;
~r1.reset;*/

// Synth(\Snare);


)












# spielwerk

spielwerk is a sequencer for monome norns + crow (arc optional) providing two independent euclidean rhythms and two CVs, that are derived from these rhythms.

_this is a work in progress, so handle with care.._

## norns

* enc 1: navigate
* enc 2: set pulses for active euclidean sequence
* enc 3: set steps for active euclidean sequence
* hold key 1 + enc 1: set bpm for active cv/euclidean sequence

## crow

* output 1: cv sequence 1, generated from the three euclidean rhythms
* output 2: triggers for euclidean rhythm 1
* output 3: triggers for euclidean rhythm 2
* output 4: cv sequence 2, generated from the three euclidean rhythms

## arc

arc displays the two cv values on ring 1 and 4, and the euclidean sequences on ring 2 and 3.

* encoder: change bpm for sequence
* norns key 2 + encoder: change pulses for euclidean sequence
* norns key 3 + encoder: change steps for euclidean sequence

## ii

if you have a mannequins just friends connected to crow via ii, you can activate sequencing for just friends in the parameters menu.
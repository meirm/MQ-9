#Place holder
var getTrackData = func {
# print("My test module got loaded!");
 var rngM=110000.0;
 var brg=0.0;
var tgt=geo.click_position();
if (tgt != nil){
	#print ("ping");
	var ac=geo.aircraft_position();
	var distance = ac.distance_to(tgt);
        var bearing =ac.course_to(tgt);
 	rngM=distance;
	brg=bearing;
	settimer(getTrackData, 0.1);
}
#
# # finally, write the result to the property tree using the setprop() call
 setprop("/tracking/rng-km", rngM * 0.001);
 setprop("/tracking/rng-nml", rngM * 0.000539957);
 setprop("/tracking/bearing",brg);
}

setlistener("sim/signals/click", getTrackData,1);

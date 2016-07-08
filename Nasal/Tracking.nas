#Place holder
var getTrackData = func {
#                me.ac = geo.aircraft_position();
#                me.distance = me.ac.distance_to(me.coord);
#                me.bearing = me.ac.course_to(me.coord);

#                var dalt = alt - me.ac.alt();
#                var ac_hdg = getprop("/orientation/heading-deg");
#                var ac_pitch = getprop("/orientation/pitch-deg");
#                var ac_contact_dist = getprop("/systems/refuel/contact-radius-m");
#                var elev = math.atan2(dalt, me.distance) * R2D;
#

# print("My test module got loaded!");
#var broken = func {
 var rngM=110000.0;
 var brg=0.0;
# 
var tgt=geo.click_position();
if (tgt != nil){
	var ac=geo.aircraft_position();
	var distance = ac.distance_to(tgt);
        var bearing =ac.course_to(tgt);
 #setprop("/tracking/test",tgt.lat());
 	rngM=distance;
	brg=bearing;
}
#
# # finally, write the result to the property tree using the setprop() call
 #setprop("tracking/engine[0]/egt-degc", degC);
 setprop("/tracking/rng-km", rngM * 0.001);
 setprop("/tracking/rng-nml", rngM * 0.000539957);
 setprop("/tracking/bearing",brg);
}

setlistener("sim/signals/click", getTrackData,1);
#settimer(getTrackData, 0.1);

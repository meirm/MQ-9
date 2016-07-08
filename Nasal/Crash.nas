setlistener("sim/crashed", func() {
    var crash = getprop("sim/crashed");

    if (crash){
       var ctext = "Airplane crashed";
       screen.log.write(ctext);
    }
});
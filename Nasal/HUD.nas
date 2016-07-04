# turn off hud in views
setlistener("/sim/current-view/view-number", func(n) { setprop("/sim/hud/visibility[1]", n.getValue() == 8) },1);

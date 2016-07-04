
=== COMBINED  REMBRANDT/NON REMBRANDT LIGHTING KIT ===
by FGUK.eu

This lighting kit lets you easily add both Rembrandt and non Rembrandt external lighting to an aircraft only by including the base pack XML and editing the coordinates there. This pack heavily depends on the Nasal script which is included both as a standalone script file (for direct inclusion in the aircrafts -set.xml file) and also in the multiplayer code inside the aircraft model xml file (in the <nasal></nasal> tags). 
The XML files contained in this archive contain an auto switching code to change between Rembrandt and non Rembrandt lighting. Fake non Rembrandt light cones are included, but commented out by default (see files Lights/LandingLight.xml and Lights/TaxiLight.xml). 
Flares, fake cones and Rembrandt lights properly fade out in daylight. 
IMPORTANT NOTE: once applied to an aircraft, it will be compatible with FlightGear versions 2.11+ only. 

Some of the Rembrandt light features show only with the light shader being set high enough (landing, taxi >0, nav lights, beacon and other external lights >1). 


=== INSTRUCTIONS ===

IMPORTANT: You don't need to go through any other files than explicitly mentioned in this readme. Multiplayer support is handled by Nasal code mirroring the multiplayer transferred properties to their original counterparts. Don't include any properties like sim/multiplay/generic/int[3] anywhere else than in the variables specially designed for this in the Nasal code. All the output properties (written to by Nasal) are placed in the node "/lightpack" and are not supposed to be changed. 


You only need to embed one xml file in your aircraft model xml: LightPack.xml
Most further editing will take place in that file. Include it in your aircraft model file like this: 

  <!-- LIGHTS -->
  <model>
    <name>LightPack</name>
    <path>Aircraft/YOURAIRCRAFT/Models/Lights/LightPack.xml</path>
  </model>

In this file, all the light files (which are themselves including the Rembrandt, flare, etc. model files) are referenced. 
Modify the coordinates of placement of the lights here. Follow any instructions in comments. 


Place the folder "Lights" in the folder "Models" in your aircraft base folder. The capital letter on the start (both Lights and Models) matters - if you change the letter case, all the xml files will fail to load on other systems than Windows (Windows does not have case sensitive paths, other systems usually have). 
If you already have your Models folder with lowercase m (or any other name change), you will need to change this in all the paths where you changed the YOURAIRCRAFT string to the aircraft base folder name (list of the files follows later in this readme). 
Note that this pack cannot handle material animations on your aircraft parts (reflectors of landing lights, nav lights models etc.). If desired, you need to include them in your aircraft's model file. Chances are you already have these done, in this case you only need to change the properties they depend on. The properties for this are:

  lightpack/nav-lights-intensity
  lightpack/beacon-state/state
  lightpack/strobe-state/state
  lightpack/landing-lights-intensity
  lightpack/taxi-light-intensity
  lightpack/probe-light-intensity
  lightpack/white-light-intensity

The names are self-explanatory. Use these properties, not the switch properties - these properties are nicely interpolated when turned on/off etc. 
As will be explained later, they are also the only properties that guarantee multiplayer support (they are manipulated exclusively by Nasal). 


You will need to replace all occurrences of YOURAIRCRAFT string in paths with your aircraft base folder name. This needs to be done in the following files: 

  TaxiLight.xml
  RedLight.xml
  LandingLight.xml
  WhiteLight.xml
  Strobe.xml
  LightPack.xml
  Beacon.xml
  ProbeLight.xml
  GreenLight.xml

Those are just all the files in the base folder, there is no other file where you need to do this. You can easily use mass search and replace with your favorite text editor. 


You need to add the file Lights.nas to your aircraft's folder with Nasal scripts and reference it in your Aircraft-set.xml file, like this: 

  <nasal>
    <!-- other Nasal includes -->
    <lights>
      <file>Aircraft/YOURAIRCRAFT/Nasal/Lights.nas</file>
    </lights>
    <!-- other Nasal includes -->
  </nasal>

You need to edit some simple property bindings in this file. On the beginning of the file, you will see these lines:

  #list of switches for lights - if you don't intend to use some light, assign it nil value instead, like whateverSwitch = nil; and you don't need to care about anything else
  var navSwitch = "/controls/lighting/nav-lights-switch";
  var beaconSwitch = "/controls/lighting/beacon-switch";
  var strobeSwitch = "/controls/lighting/strobe-switch";
  var landingSwitch = "/controls/lighting/landing-lights-switch";
  var taxiSwitch = "/controls/lighting/taxi-light-switch";
  var probeSwitch = "/controls/lighting/probe-light-switch";
  var whiteSwitch = "/controls/lighting/white-light-switch";

Edit those property bindings. They are used as a boolean on/off switch and are supposed to be MP transferred by binding them to the MP trasferred integers. You can set those properties as you wish, according to your current switch setup. 
If you don't want to use some of the lights provided at all, just assign a nil value here instead of the string: 

  var whateverSwitch = nil;

The code handles this properly and doesn't create the output property for it. It's not entirely necessary, but preferred to delete/comment out any of the unused lights in the file LightPack.xml


Now you are one last step from the finish. All that is left is to add a multiplayer support. 
As mentioned in the Nasal part, the on/off switch properties are expected to be bound to MP transferred properties. You need to embed a Nasal code in your aircraft's model xml file, between the <nasal></nasal> tags. The code is too long to be included here (>90% is the same as in Lights.nas), find the code in the file YOURAIRCRAFT.xml
You will find there part very similar to the previous switches bindings in the local Nasal: 

  #list of switches for lights - if you don't intend to use some light, assign it nil value instead, like whateverSwitch = nil; and you don't need to care about anything else
  #IMPORTANT: don't put / on the start of the string, it's already included in the mpPath property
  var navSwitch = mpPath~"controls/lighting/nav-lights-switch";
  var beaconSwitch = mpPath~"controls/lighting/beacon-switch";
  var strobeSwitch = mpPath~"controls/lighting/strobe-switch";
  var landingSwitch = mpPath~"controls/lighting/landing-lights-switch";
  var taxiSwitch = mpPath~"controls/lighting/taxi-light-switch";
  var probeSwitch = mpPath~"controls/lighting/probe-light-switch";
  var whiteSwitch = mpPath~"controls/lighting/white-light-switch";

You need to put there the same property paths as before, but now the string is appended to a previously generated MP prefix. Don't include the leading slash, it is in the prefix already. It is crucial those bindings are the same as in the local Nasal. 

You also need to specify the MP properties used for transfer, so Nasal knows which MP property should be watched and mirrored to which original property. Look for a chunk of code looking like this: 

  #init any property copy object needed in this array (anything you need to transfer over MP, but you are using the original paths in your xmls)
  #also used for properties you are using a listener on, or properties which you maybe want to manipulate during the <unload> 
  #if you're just using the pack, change the values according to the MP bindings in the -set.xml file
  #you don't need to delete the entries if the path is nil - it gets skipped automatically and the MP path is just ignored
  var mirrorValues = [
    mpVar.new(mpPath~"sim/multiplay/generic/int[7]", mpPath~"sim/crashed"),
    mpVar.new(mpPath~"sim/multiplay/generic/int[0]", navSwitch),
    mpVar.new(mpPath~"sim/multiplay/generic/int[1]", beaconSwitch),
    mpVar.new(mpPath~"sim/multiplay/generic/int[1]", strobeSwitch),
    mpVar.new(mpPath~"sim/multiplay/generic/int[2]", landingSwitch),
    mpVar.new(mpPath~"sim/multiplay/generic/int[3]", taxiSwitch),
    mpVar.new(mpPath~"sim/multiplay/generic/int[3]", probeSwitch),
    mpVar.new(mpPath~"sim/multiplay/generic/int[0]", whiteSwitch),
  ];

Here you see the previously assembled strings. You don't need to care about those at all - just change the number in the square brackets to whatever is the index of the MP property that represents the property on the right. It is essential that this is paired in exactly the same way as the properties are assigned in your -set file. 
If you assigned nil to some switch, you don't need to care about the line where it is used. It just gets ignored, so the index doesn't matter. 
If you want to add any light unrelated property to the copy mechanism, just add a new line in the array, following the same pattern. 


And that's it, you just got yourself a brand new and awesome lighting effects :)



=== FURTHER TUNING ===

If you want to have the navigation lights use nice periodically fading behavior instead of being continuously on when the switch is on, change the line just below the switch property path assignments in the file Lights.nas: 

  #switch this from 1 to 0 if you want to use advanced cyclical fading animation of the the nav lights instead of being stable on when the switch is on
  navStillOn = 1;

This doesn't mean they are on all the time, they still depend on the switch property. They just don't perform periodical fade-in-out animation when the value is 1. 
Change it in the MP support Nasal code in your aircraft model xml file as well. 
In case you use the fading animation, you can easily change the duration of the phases just after line 80 in Lights.nas. Of course equivalent change needs to be done in the MP code as well. 


If you want the landing and taxi lights switches bound to the landing gear, change this line below the switch property path assignments in the file Lights.nas: 

  #switch this from 0 to 1 if you want to bind the landing and taxi lights to the landing gear
  gearBind = 0;

This again handles the nil values correctly if you're not using one of the lights. 


If you want to tune the lights, like setting custom animation times, read through the Nasal, there are comments explaining the variables. The code uses object-oriented approach - don't edit the class implementation! Only assign the values to the members of the created objects. You will need to do this in both the local and the model-embedded Nasal code, but don't be afraid, thanks to a good design they are identical (except for the first few lines needed to set up the environment). 



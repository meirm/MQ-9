#Turret by 5H1N0B1
#GNU licence

#turret Gun class
var turret=
{
  #create new object
  new: func(name,index, view_number,heading_path,pitch_path,minhead, maxhead,headdegsec,minpitch, maxpitch,pitchdegsec)
  {
    # copy the turret object
    var m = { parents: [turret] };
    m.name = name;
    m.index = index;
    m.view = view_number;
    m.viewheading = props.globals.getNode("/sim/current-view/heading-offset-deg");
    m.viewpitch = props.globals.getNode("/sim/current-view/pitch-offset-deg");
    m.loop_running = 0;
    
    #Heading management
    m.heading = props.globals.getNode(heading_path);
    m.heading_Min = minhead;
    m.heading_Max = maxhead;
    m.headingDegBySec = headdegsec;
    m.LastHeading = 0;
    
    #Ptich management
    m.pitch   = props.globals.getNode(pitch_path);
    m.pitch_Min = minpitch;
    m.pitch_Max = maxpitch;
    m.pitchDegBySec = pitchdegsec;
    m.LastPitch = 0;
    
    #Self Update period
    m.UPDATE_PERIOD = 0.04 ; # update interval for engine init() functions
    m.LastTime = 0;
    
    #SetListener
    m.viewChange   = nil;
    m.viewPitch    = nil;
    m.viewHeading  = nil;
    
    return m;
  },
    
  #In case of new without limitations arguments 
  #new: func(name,index, view_number,heading_path,pitch_path)
  #{
  # var m = turret.new(name,index,view_number,heading_path, pitch_path,0 ,0 ,0 ,0);
  # return m;
  #},
  #move the turret
  move: func
  {
    #print("L4");
    var ActTime = getprop("sim/time/elapsed-sec");
    var headingcoeff = 0;
    var pitchcoeff = 0;
          
    #degTime
          
    #----------------Heading----------------
    var Myheading = 360-me.viewheading.getValue();

    #Heading coeff
    headingcoeff = (ActTime - me.LastTime)*me.headingDegBySec;
    
    #Heading coeff limitation
    headingcoeff = (headingcoeff-abs(Myheading - me.LastHeading)>0)? abs(Myheading - me.LastHeading):headingcoeff;
    #Add sign
    headingcoeff = (Myheading - me.LastHeading)<0? -headingcoeff:headingcoeff;
    #Invert it when angle>180
    headingcoeff = abs(Myheading - me.LastHeading)>180?-headingcoeff:headingcoeff;
                
    #This is to take account of the modulo 2Pi
    Myheading = headingcoeff+me.LastHeading;
    Myheading = Myheading>360?Myheading-360:Myheading;
    Myheading = Myheading<0?360-Myheading:Myheading;
                
    #Limitation
    Myheading = me.limit(Myheading,me.heading_Min,me.heading_Max,me.LastHeading);
    me.heading.setValue(Myheading); 
    me.LastHeading = Myheading;
          
    #gui.popupTip (Myheading,0.1);

    #-----------------Pitch-----------------
    var Mypitch = me.viewpitch.getValue();
                     
    #Pitch coeff
    pitchcoeff = (ActTime - me.LastTime)*me.headingDegBySec;
                
    #Pitch coeff limitation
    pitchcoeff = (pitchcoeff-abs(Mypitch - me.LastPitch)>0)? abs(Mypitch - me.LastPitch):pitchcoeff;
    #Add sign
    pitchcoeff = (Mypitch - me.LastPitch)<0? -pitchcoeff:pitchcoeff;
                
    Mypitch = pitchcoeff+me.LastPitch;
 
    #Limitation
    Mypitch = me.limit(Mypitch,me.pitch_Min,me.pitch_Max,me.LastPitch);
    me.pitch.setValue(Mypitch);
    me.LastPitch = Mypitch;
                
    #Free for anotherupdate
    #me.loop_running = 0;
    me.LastTime = ActTime;
  },
  
  #Tool : limitations func.
  limit: func(value, min, max, lastValue)
  {
    var tempo = value;
    if(max != min) {
      if(max>min) {                
        if(value>max) {
          tempo = max;
        }
        if(value<min) {
          tempo = min;
        }
      } else {
	#print("min:",min,", max:",max," value:",value, " LastValue", lastValue);
        if((value>max) and (value<min) and (lastValue>=min)) {
          tempo = min;
        }
        if((value>max) and (value<min) and (lastValue<=max)) {
          tempo = max;
        }
      }
    }
    #print("value :",value," tempo :",tempo, "min :", min," max :",max);
    return tempo
  },
  
  #Call the update loop
  init: func
  {
    #settimer(loop, 0);
    if(me.viewChange == nil) {
      me.viewChange = setlistener("sim/current-view/view-number", func(currentView) {
        #print("L1 ", me.loop_running);                                     
        if(currentView.getValue() == me.view) {
          #print("L1 prime", me.loop_running); 
          me.update();
          removelistener(me.viewChange);
          #me.listening();
        }
      }, 0, 0);
    }  
  },
  #Create the update loop and the listener -->The ideal would be to put a setlistener/view
  update: func
  {
    if (me.loop_running) return;
    #me.loop_running = 1;
    var loop = func {
      #print("3");
      if(getprop("sim/current-view/view-number") == me.view) { 
        me.move();
        me.UPDATE_PERIOD = 0.04;
      } else {
        me.UPDATE_PERIOD = 1;
      }
      settimer(loop, me.UPDATE_PERIOD);
    }
    settimer(loop, me.UPDATE_PERIOD);
  },
        
  update_2: func
  {        
  },
        
  #Set/change update period if necessary
  update_period: func (update_periode)
  {
    me.UPDATE_PERIOD = update_periode;
  }
};
     
#  nom     : TourelledeToit
#  index   :  0 <-Il s'agit de la première tourelle, la variable est definie dans sim/model/turret[0]
#  view    :  9 Il s'agit de l'index reel de la view, disponible ici : /sim/current-view/view-number
#  heading : path de la variable heading du model 3D
#  pitch   : path de la variable pitch du model 3D
#  heading, min max : limitations en heading. Si max = min alors pas de limitation
#  pitch, min max : limitations en pitch. Si max = min alors pas de limitation
    
#In English : here are the parameters : 
#func(name,index, view_number,heading_path,pitch_path,minhead, maxhead,headdegsec,minpitch, maxpitch,pitchdegsec)
#  name          : TourelledeToit (Name it as you wish)
#  index         :  0 <-Here it's the first turret, so 0. Variable can be found here :  sim/model/turret[0]
#  view          :  9 View index. Can be found here : /sim/current-view/view-number
#  heading_path  :  heading_path of the turret. 3D model move based on this.(Submodels&bullets too)
#  pitch_path    :  pitch path  of the turret. 3D model move based on this.(Submodels&bullets too)
#heading, min max: heading limitation, min & max. if max=min : no limitation
#headdegsec      : Turret heading turn rate in degree/seconds
#pitch, min max  : pitch limitation, min & max. if max=min : no limitation
#pitchdegsec     : Turret pitch turn rate in degree/seconds
    
#création de l'objet    
var tourelleCanon = turret.new("tourelleCanon",0,8,"sim/model/turret[0]/heading","sim/model/turret[0]/pitch",270,90,60,-70,10,60);
var tourelleCanon2 = turret.new("tourelleCanon",0,9,"sim/model/turret[0]/heading","sim/model/turret[0]/pitch",270,90,60,-70,10,60);

          
#init de l'objet
var myListener = setlistener("sim/signals/fdm-initialized", func
{
  tourelleCanon.init();
  tourelleCanon2.init();
  removelistener(myListener);
}, 0, 0);    
    
#Note : pour rajouter une tourelle, s'assurer que les variables soient bonne, que la 3D soit présente. Ensuite Il suffit d'ajouter : 
# var tourelledetoit = turret.new("TourelledeToit",0,9,"sim/model/turret[0]/heading","sim/model/turret[0]/pitch");
# setlistener("sim/signals/fdm-initialized", func
#    tourelledetoit.init();
#}, 0, 0);
        
#la gestion des tir n'a pas encore été faite
//Turrets
//
//
float g_spawnturretsaround;
//float autocvar_g_spawnturretsaround_per;
//float autocvar_g_spawnturretsaround_max;
float g_spawnturretsaround_current;
float g_spawnturretsaroundwalker_current;
float g_spawnturretsaroundreactor_current;

vector Tr_Select_Spawn_Point(void)
{
	entity e = spawn();
	e.mins = '-32 -32 -32';
	e.maxs = '32 32 32';

	// tries 10 times then gives up, that's what the number 10 stands for
	if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 1))
	{
		// yay we found a suitable location!
		vector selected_origin = e.origin;
		remove(e);
		//dprint("^4SUCCESS: we found a suitable location for TURRET\n");
		return selected_origin;
	}
	else
	{
		// no place found, better luck next time
		remove(e);
		return '0 0 0';
	}
}

float Tr_Spawn_Turrets(void)
{
	if (g_spawnturretsaround_current >= cvar("g_spawnturretsaround_max")) {
		//dprint("We have enough turrets\n");
		return 0;
	}
	
	float spawns_we_want = cvar("g_spawnturretsaround_per");
	float i = 0;
	vector selected_origin = '0 0 0';

	//dprint("Spawning Turret\n");
	for(i = 1; i <= spawns_we_want;)
	{
		selected_origin = Tr_Select_Spawn_Point();
		if(selected_origin != '0 0 0')
		{
			entity previousself = self;
			entity e = spawn();
			e.origin = selected_origin;
			e.angles_y = random() * 180;
			e.fixangle = TRUE;
			self = e;
			
			float randvar;
			randvar = random() * 100;
			if (randvar > 90) {
				spawnfunc_turret_hk();
			} else if(randvar > 80) {
				spawnfunc_turret_hellion();
			} else if(randvar > 70) {
				spawnfunc_turret_phaser();
			} else if(randvar > 60) {
				spawnfunc_turret_plasma_dual();
			} else if(randvar > 50) {
				spawnfunc_turret_mlrs();
			} else if(randvar > 30) {
				spawnfunc_turret_plasma();
			} else if(randvar > 20) {
				spawnfunc_turret_tesla();
			} else{
				spawnfunc_turret_machinegun();
			}
			
			setorigin(self, self.origin);
       			tracebox(self.origin + '0 0 100', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
        		setorigin(self, trace_endpos);
						
			self = previousself;

			++i; // we found a spot, lets progress to the next one now
			g_spawnturretsaround_current = g_spawnturretsaround_current + 1;
		}
	}
	return TRUE;
}

float Tr_Spawn_Walkers(void)
{
	if (g_spawnturretsaroundwalker_current >= cvar("g_spawnturretsaroundwalker_max")) {
		//dprint("We have enough walker turrets\n");
		return 0;
	}
	
	float spawns_we_want = cvar("g_spawnturretsaroundwalker_per");
	float i = 0;
	vector selected_origin = '0 0 0';

	//dprint("Spawning Turret\n");
	for(i = 1; i <= spawns_we_want;)
	{
		selected_origin = Tr_Select_Spawn_Point();
		if(selected_origin != '0 0 0')
		{
			entity previousself = self;
			entity e = spawn();
			e.origin = selected_origin;
			e.angles_y = random() * 180;
			e.fixangle = TRUE;
			self = e;
			
			float randvar;
			randvar = random() * 100;
			if(randvar > 60) {
				spawnfunc_turret_walker();
			} else {
				spawnfunc_turret_ewheel();
			}
			
			setorigin(self, self.origin);
       			tracebox(self.origin + '0 0 100', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
        		setorigin(self, trace_endpos);
						
			self = previousself;

			++i; // we found a spot, lets progress to the next one now
			g_spawnturretsaroundwalker_current = g_spawnturretsaroundwalker_current + 1;
		}
	}
	return TRUE;
}


const vector IMP_MINS = '-49.9 -41.5   0.0';
const vector IMP_MAXS = ' 50.3  42.8 160.0';
const float  IMP_MODELSCALE = 3;

#define IMP_ANIM_STILL 0
#define IMP_ANIM_WALK 1
#define IMP_ANIM_ATTACK 2

void monster_imp_walk() {
	self.frame = IMP_ANIM_WALK;
	
	print("imp walk\n");
	print("^6", vtos(self.mins), " ======= ", vtos(self.maxs), "\n");
	
	self.angles_y = approach(self.angles_y, self.ideal_yaw, self.yaw_speed);
	makevectors(self.angles);
	self.velocity = 50 * v_forward;
	
	print("angles = ", vtos(self.angles), "\n");
}

void monster_imp_stand() {
	self.frame = IMP_ANIM_STILL;
	print("imp stand\n");
}

monster_setup_f monster_imp_setup = {
	monster_setup_common();
	
	self.health = 1000;
	self.model = "models/imp.md2";
	setmodel(self, self.model);
	self.frame = IMP_ANIM_WALK;
	self.scale = IMP_MODELSCALE;
	setsize(self, IMP_MINS, IMP_MAXS);
	droptofloor();
	
	self.th_walk = monster_imp_walk;
	self.th_stand = monster_imp_stand;
	
	self.spawnflags = self.spawnflags | MONSTER_WANDER;
	walkmonster_start();
}

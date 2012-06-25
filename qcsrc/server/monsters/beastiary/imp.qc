
const vector IMP_MINS = '-49.9 -41.5   0.0';
const vector IMP_MAXS = ' 50.3  42.8 160.0';
const float  IMP_MODELSCALE = 3;

.entity imphand;

#define IMP_ANIM_STILL 0
#define IMP_ANIM_WALK 1
#define IMP_ANIM_ATTACK 2

void monster_imp_stand() {
	self.frame = IMP_ANIM_STILL;
	monster_stop();
}

void monster_imp_walk() {
	
	if(self.cnt > time) {
		monster_stop();
		monster_turntogoal(TRUE, self.enemy.origin);
		
		if(self.frame == IMP_ANIM_WALK)
			monster_imp_stand();
		return;
	}
	
	self.frame = IMP_ANIM_WALK;
	
	FindTarget();
	
	if(self.enemy) {
		monster_run();
		return;
	}
	
	monster_walk();
}

void imp_missle_fire() {
	local entity proj;

	proj = spawn ();
	proj.owner = self;
	proj.classname = "imp_fireball";
	proj.movetype = MOVETYPE_BOUNCEMISSILE;
	proj.projectiledeathtype = DEATH_HG_NAPALM;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '0 0 0', '0 0 0');
	proj.think = HG_Napalm_Think;
	proj.nextthink = time;
	proj.damageforcescale = 1;
	
	makevectors(self.angles);
	setorigin(proj, self.origin + v_up * 90 + v_right * 30);
	
	vector shotanle = vectoangles(proj.origin - self.enemy.origin);
	shotanle_y += 180;
	makevectors(shotanle);
	proj.velocity = v_forward * 400;
	
	proj.pushltime = time + 3;
	W_SetupProjectileVelocity(proj);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;

	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);
}

void monster_imp_missile() {
	self.jb_torture_suggestedforce = 1000;
	ATTACK_FINISHED(self) = time + 6/7 + 1;
	self.cnt = time + 6/7;
	self.frame = IMP_ANIM_ATTACK;
	monster_stop();
	imp_missle_fire();
}

void imp_hand_think() {
	self.frame = self.owner.frame;
	self.nextthink = time;
}

void imp_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {
	print("IMP DAMAGE\n");
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
	
	entity hand = spawn();
	setmodel(hand, "models/imp_hand.md2");
	hand.owner = self;
	hand.think = imp_hand_think;
	hand.nextthink = time;
	self.imphand = hand;
	setattachment(hand, self, "");
	
	self.mon_speed = 50;
	self.mon_runspeed = 150;
	
	self.th_walk = monster_imp_walk;
	self.th_stand = monster_imp_stand;
	self.th_missile = monster_imp_missile;
	self.event_damage = imp_damage;
	self.damageforcescale = 1;
	self.mon_drunkenness = 10;
	
	walkmonster_start();
}


.float  roomtype;
.float  radius;
.float  pitch;
.float  renderamt;
.float  rendermode;
.vector rendercolor;

void func_ladder_touch()
{
	if not(other.iscreature)
		return;

	EXACTTRIGGER_TOUCH;

	other.ladder_time = time + 0.1;
	other.ladder_entity = self;
};

void spawnfunc_func_ladder()
{
	EXACTTRIGGER_INIT;
	self.touch = func_ladder_touch;
};

void spawnfunc_func_water()
{
	EXACTTRIGGER_INIT;
	self.touch = func_ladder_touch;
};



IPOL_SHORTDEF(linear, x)

float ipol_powIn(float p, float x) {
	return pow(x, p);
}


float ipol_powOut(float p, float x) {
	return pow(x - 1, p) * (mod(p, 2)? 1 : -1) + 1;
}


float ipol_powInOut(float p, float x) {
	if(x <= 0.5f)
		return pow(x * 2, p) / 2;
	return pow((x - 1) * 2, p) / (mod(p, 2)? 2 : -2) + 1;
}

IPOL_SHORTDEF(pow2In, 		ipol_powIn(2, x))
IPOL_SHORTDEF(pow2Out, 		ipol_powOut(2, x))
IPOL_SHORTDEF(pow2InOut, 	ipol_powInOut(2, x))

IPOL_DEF(swingInOut) {
	float scl = 3;
	
	if(x <= 0.5f) {
		x *= 2;
		return x * x * ((scl + 1) * x - scl) / 2;
	}
	x--;
	x *= 2;
	return x * x * ((scl + 1) * x + scl) / 2 + 1;
}

IPOL_DEF(swingOut) {
	x--;
	return x * x * (3 * x + 2) + 1;
}

IPOL_SHORTDEF(swingIn, 	x * x * (3 * x - 2))

// Part of NEXSTAT Mod

void StatsPushPlayer(string type, entity player, entity param) {
	string q;
	q = strcat("nexstat:", ftos(cvar("port")));
	if (type == "kill") {
		q = strcat(q, ":3:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":", ftos(strlen(player.netname)) , ":");
		q = strcat(q, player.netname, ":", ftos(strlen(param.netaddress)), ":", param.netaddress, ":");
		q = strcat(q, ftos(strlen(param.netname)) , ":", param.netname);
		print(q);
	} else if (type == "death") {
		q = strcat(q, ":4:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":", ftos(strlen(player.netname)) , ":");
		q = strcat(q, player.netname, ":", ftos(strlen(param.netaddress)), ":", param.netaddress, ":");
		q = strcat(q, ftos(strlen(param.netname)) , ":", param.netname);
		print(q);
	} else if (type == "fckill") {
		q = strcat(q, ":8:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":", ftos(strlen(player.netname)) , ":");
		q = strcat(q, player.netname, ":", ftos(strlen(param.netaddress)), ":", param.netaddress, ":");
		q = strcat(q, ftos(strlen(param.netname)) , ":", param.netname);
		print(q);
	}
}

void StatsPushString(string type, entity player, string param) {
	string q;
	q = strcat("nexstat:", ftos(cvar("port")));
	if (type == "lost") {
		q = strcat(q, ":a:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":" , ftos(strlen(player.netname)));
		q = strcat(q, ":", player.netname, ":", ftos(strlen(param)), ":", param);
		print(q);
	} else if (type == "return") {
		q = strcat(q, ":9:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":" , ftos(strlen(player.netname)));
		q = strcat(q, ":", player.netname, ":", ftos(strlen(param)), ":", param);
		print(q);
	} else if (type == "capture") {
		q = strcat(q, ":5:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":" , ftos(strlen(player.netname)));
		q = strcat(q, ":", player.netname, ":", ftos(strlen(param)), ":", param);
		print(q);
	} else if (type == "pickup") {
		q = strcat(q, ":6:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":" , ftos(strlen(player.netname)));
		q = strcat(q, ":", player.netname, ":", ftos(strlen(param)), ":", param);
		print(q);
	}
}

void StatsPushVoid(string type, entity player) {
	string q;
	q = strcat("nexstat:", ftos(cvar("port")));
	if (type == "connect") {
		q = strcat(q, ":1:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":" , ftos(strlen(player.netname)));
		q = strcat(q, ":", player.netname);
		print(q);
	} else if (type == "join") {
		q = strcat(q, ":2:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":" , ftos(strlen(player.netname)));
		q = strcat(q, ":", player.netname);
		print(q);
	} else if (type == "suicide") {
		q = strcat(q, ":7:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":" , ftos(strlen(player.netname)));
		q = strcat(q, ":", player.netname);
		print(q);
	} else if (type == "shot") {
		q = strcat(q, ":b:", ftos(strlen(player.netaddress)), ":", player.netaddress, ":" , ftos(strlen(player.netname)));
		q = strcat(q, ":", player.netname);
		print(q);
	}
}

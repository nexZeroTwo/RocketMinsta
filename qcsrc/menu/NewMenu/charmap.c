#ifdef INTERFACE
CLASS(NewMenuCharmap) EXTENDS(Image)
	METHOD(NewMenuCharmap, configureNewMenuCharmap, void(entity, entity))
	METHOD(NewMenuCharmap, mousePress, float(entity, vector))
	METHOD(NewMenuCharmap, mouseRelease, float(entity, vector))
	METHOD(NewMenuCharmap, mouseMove, float(entity, vector))
	METHOD(NewMenuCharmap, mouseDrag, float(entity, vector))
	METHOD(NewMenuCharmap, keyDown, float(entity, float, float, float))
	METHOD(NewMenuCharmap, focusLeave, void(entity))
	METHOD(NewMenuCharmap, draw, void(entity))
	ATTRIB(NewMenuCharmap, controlledTextbox, entity, NULL)
	ATTRIB(NewMenuCharmap, image, string, SKINGFX_CHARMAP)
	ATTRIB(NewMenuCharmap, image2, string, SKINGFX_CHARMAP_SELECTED)
	ATTRIB(NewMenuCharmap, focusable, float, 1)
	ATTRIB(NewMenuCharmap, previouslySelectedCharacterCell, float, -1)
	ATTRIB(NewMenuCharmap, selectedCharacterCell, float, 0)
	ATTRIB(NewMenuCharmap, mouseSelectedCharacterCell, float, -1)
ENDCLASS(NewMenuCharmap)
entity makeNewMenuCharmap(entity theTextbox);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuCharmap(entity theTextbox)
{
	entity me;
	me = spawnNewMenuCharmap();
	me.configureNewMenuCharmap(me, theTextbox);
	return me;
}

string CharMap_CellToChar(float c)
{
	if(c == 13)
		return chr(127);
	else if(c < 32)
		return chr(c);
	else
		return chr(c + 96);
}

void configureNewMenuCharmapNewMenuCharmap(entity me, entity theTextbox)
{
	me.controlledTextbox = theTextbox;
	me.configureImage(me, me.image);
}

float mouseMoveNewMenuCharmap(entity me, vector coords)
{
	float x, y, c;
	x = floor(coords_x * 16);
	y = floor(coords_y * 10);
	if(x < 0 || y < 0 || x >= 16 || y >= 10)
	{
		me.mouseSelectedCharacterCell = -1;
		return 0;
	}
	c = y * 16 + x;
	if(c != me.mouseSelectedCharacterCell)
		me.mouseSelectedCharacterCell = me.selectedCharacterCell = c;
	return 1;
}
float mouseDragNewMenuCharmap(entity me, vector coords)
{
	return me.mouseMove(me, coords);
}
float mousePressNewMenuCharmap(entity me, vector coords)
{
	me.mouseMove(me, coords);
	if(me.mouseSelectedCharacterCell >= 0)
	{
		me.pressed = 1;
		me.previouslySelectedCharacterCell = me.selectedCharacterCell;
	}
	return 1;
}
float mouseReleaseNewMenuCharmap(entity me, vector coords)
{
	if(!me.pressed)
		return 0;
	me.mouseMove(me, coords);
	if(me.selectedCharacterCell == me.previouslySelectedCharacterCell)
		me.controlledTextbox.enterText(me.controlledTextbox, CharMap_CellToChar(me.selectedCharacterCell));
	me.pressed = 0;
	return 1;
}
float keyDownNewMenuCharmap(entity me, float key, float ascii, float shift)
{
	switch(key)
	{
		case K_LEFTARROW:
			me.selectedCharacterCell = mod(me.selectedCharacterCell + 159, 160);
			return 1;
		case K_RIGHTARROW:
			me.selectedCharacterCell = mod(me.selectedCharacterCell + 1, 160);
			return 1;
		case K_UPARROW:
			me.selectedCharacterCell = mod(me.selectedCharacterCell + 144, 160);
			return 1;
		case K_DOWNARROW:
			me.selectedCharacterCell = mod(me.selectedCharacterCell + 16, 160);
			return 1;
		case K_HOME:
			me.selectedCharacterCell = 0;
			return 1;
		case K_END:
			me.selectedCharacterCell = 159;
			return 1;
		case K_SPACE:
		case K_ENTER:
		case K_INS:
			me.controlledTextbox.enterText(me.controlledTextbox, CharMap_CellToChar(me.selectedCharacterCell));
			return 1;
		default:
			return me.controlledTextbox.keyDown(me.controlledTextbox, key, ascii, shift);
	}
}
void focusLeaveNewMenuCharmap(entity me)
{
	me.controlledTextbox.saveCvars(me.controlledTextbox);
}
void drawNewMenuCharmap(entity me)
{
	if(me.focused)
	{
		if(!me.pressed || (me.selectedCharacterCell == me.previouslySelectedCharacterCell))
		{
			vector c;
			c = eX * (mod(me.selectedCharacterCell, 16) / 16.0);
			c += eY * (floor(me.selectedCharacterCell / 16.0) / 10.0);
			draw_Picture(c, me.image2, '0.0625 0.1 0', '1 1 1', 1);
		}
	}
	drawImage(me);
}
#endif

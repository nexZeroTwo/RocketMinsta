#ifdef INTERFACE
CLASS(NewMenuColorpicker) EXTENDS(Image)
	METHOD(NewMenuColorpicker, configureNewMenuColorpicker, void(entity, entity))
	METHOD(NewMenuColorpicker, mousePress, float(entity, vector))
	METHOD(NewMenuColorpicker, mouseRelease, float(entity, vector))
	METHOD(NewMenuColorpicker, mouseDrag, float(entity, vector))
	ATTRIB(NewMenuColorpicker, controlledTextbox, entity, NULL)
	ATTRIB(NewMenuColorpicker, image, string, SKINGFX_COLORPICKER)
	ATTRIB(NewMenuColorpicker, imagemargin, vector, SKINMARGIN_COLORPICKER)
	ATTRIB(NewMenuColorpicker, focusable, float, 1)
	METHOD(NewMenuColorpicker, focusLeave, void(entity))
	METHOD(NewMenuColorpicker, keyDown, float(entity, float, float, float))
	METHOD(NewMenuColorpicker, draw, void(entity))
ENDCLASS(NewMenuColorpicker)
entity makeNewMenuColorpicker(entity theTextbox);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuColorpicker(entity theTextbox)
{
	entity me;
	me = spawnNewMenuColorpicker();
	me.configureNewMenuColorpicker(me, theTextbox);
	return me;
}

void configureNewMenuColorpickerNewMenuColorpicker(entity me, entity theTextbox)
{
	me.controlledTextbox = theTextbox;
	me.configureImage(me, me.image);
}

float mousePressNewMenuColorpicker(entity me, vector coords)
{
	me.mouseDrag(me, coords);
	return 1;
}

// must match hslimage.c
vector hslimage_color(vector v, vector margin)
{
    v_x = (v_x - margin_x) / (1 - 2 * margin_x);
    v_y = (v_y - margin_y) / (1 - 2 * margin_y);
    if(v_x < 0) v_x = 0;
    if(v_y < 0) v_y = 0;
    if(v_x > 1) v_x = 1;
    if(v_y > 1) v_y = 1;
    if(v_y > 0.875) // grey bar
        return hsl_to_rgb(eZ * v_x);
    else
        return hsl_to_rgb(v_x * 6 * eX + eY + v_y / 0.875 * eZ);
}

float mouseDragNewMenuColorpicker(entity me, vector coords)
{
	float i;
	for(;;)
	{
		i = me.controlledTextbox.cursorPos;
		if(i >= 2)
		{
			if(substring(me.controlledTextbox.text, i-2, 1) == "^")
				if(strstrofs("0123456789", substring(me.controlledTextbox.text, i-1, 1), 0) >= 0)
				{
					me.controlledTextbox.keyDown(me.controlledTextbox, K_BACKSPACE, 8, 0);
					me.controlledTextbox.keyDown(me.controlledTextbox, K_BACKSPACE, 8, 0);
					continue;
				}
		}

		if(i >= 5)
		{
			if(substring(me.controlledTextbox.text, i-5, 2) == "^x")
				if(strstrofs("0123456789abcdefABCDEF", substring(me.controlledTextbox.text, i-3, 1), 0) >= 0)
					if(strstrofs("0123456789abcdefABCDEF", substring(me.controlledTextbox.text, i-2, 1), 0) >= 0)
						if(strstrofs("0123456789abcdefABCDEF", substring(me.controlledTextbox.text, i-1, 1), 0) >= 0)
						{
							me.controlledTextbox.keyDown(me.controlledTextbox, K_BACKSPACE, 8, 0);
							me.controlledTextbox.keyDown(me.controlledTextbox, K_BACKSPACE, 8, 0);
							me.controlledTextbox.keyDown(me.controlledTextbox, K_BACKSPACE, 8, 0);
							me.controlledTextbox.keyDown(me.controlledTextbox, K_BACKSPACE, 8, 0);
							me.controlledTextbox.keyDown(me.controlledTextbox, K_BACKSPACE, 8, 0);
							continue;
						}
		}
		break;
	}

	vector margin;
	margin = me.imagemargin;
	if(coords_x >= margin_x)
	if(coords_y >= margin_y)
	if(coords_x <= 1 - margin_x)
	if(coords_y <= 1 - margin_y)
		me.controlledTextbox.enterText(me.controlledTextbox, rgb_to_hexcolor(hslimage_color(coords, margin)));

	return 1;
}

float mouseReleaseNewMenuColorpicker(entity me, vector coords)
{
	me.mouseDrag(me, coords);
	return 1;
}

void focusLeaveNewMenuColorpicker(entity me)
{
	me.controlledTextbox.saveCvars(me.controlledTextbox);
}
float keyDownNewMenuColorpicker(entity me, float key, float ascii, float shift)
{
	return me.controlledTextbox.keyDown(me.controlledTextbox, key, ascii, shift);
}
void drawNewMenuColorpicker(entity me)
{
	drawImage(me);

	float B, C, aC;
	C = cvar("r_textcontrast");
	B = cvar("r_textbrightness");

	// for this to work, C/(1-B) must be in 0..1
	// B must be < 1
	// C must be < 1-B
	
	B = bound(0, B, 1);
	C = bound(0, C, 1-B);

	aC = 1 - C / (1 - B);

	draw_Picture(me.imgOrigin, strcat(me.src, "_m"), me.imgSize, '0 0 0', aC);
	draw_Picture(me.imgOrigin, strcat(me.src, "_m"), me.imgSize, me.color, B);
}
#endif

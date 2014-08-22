#ifdef INTERFACE
CLASS(NewMenuWeaponsDialog) EXTENDS(NewMenuDialog)
	METHOD(NewMenuWeaponsDialog, toString, string(entity))
	METHOD(NewMenuWeaponsDialog, fill, void(entity))
	METHOD(NewMenuWeaponsDialog, showNotify, void(entity))
	ATTRIB(NewMenuWeaponsDialog, title, string, "Weapon settings")
	ATTRIB(NewMenuWeaponsDialog, color, vector, SKINCOLOR_DIALOG_WEAPONS)
	ATTRIB(NewMenuWeaponsDialog, intendedWidth, float, 0.35)
	ATTRIB(NewMenuWeaponsDialog, rows, float, 16)
	ATTRIB(NewMenuWeaponsDialog, columns, float, 4)
	ATTRIB(NewMenuWeaponsDialog, weaponsList, entity, NULL)
ENDCLASS(NewMenuWeaponsDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNewMenuWeaponsDialog(entity me)
{
        loadAllCvars(me);
}
string toStringNewMenuWeaponsDialog(entity me)
{
	return me.weaponsList.toString(me.weaponsList);
}
void fillNewMenuWeaponsDialog(entity me)
{
	entity e;
	float h0, h;

	h = me.rows - 7;
	
	me.TR(me);
		me.TD(me, 1, 4, makeNewMenuTextLabel(0, "Weapon priority list:"));
	me.TR(me);
		h0 = me.currentRow;
		me.TD(me, h, 3, e = me.weaponsList = makeNewMenuWeaponsList());
	me.gotoRC(me, h0 + h / 2 - 1, 3);
		me.TD(me, 1, 1, e = makeNewMenuButton("Up", '0 0 0'));
			e.onClick = WeaponsList_MoveUp_Click;
			e.onClickEntity = me.weaponsList;
	me.gotoRC(me, h0 + h / 2, 3);
		me.TD(me, 1, 1, e = makeNewMenuButton("Down", '0 0 0'));
			e.onClick = WeaponsList_MoveDown_Click;
			e.onClickEntity = me.weaponsList;
	me.gotoRC(me, h0 + h, 0);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "cl_weaponpriority_useforcycling", "Use priority list for weapon cycling"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "cl_autoswitch", "Auto switch weapons on pickup"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "r_drawviewmodel", "Draw 1st person weapon model"));
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeNewMenuRadioButton(1, "cl_gunalign", "4", "Left align"));
			setDependent(e, "r_drawviewmodel", 1, 1);
		me.TD(me, 1, 2, e = makeNewMenuRadioButton(1, "cl_gunalign", "3", "Right align"));
			setDependent(e, "r_drawviewmodel", 1, 1);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNewMenuCheckBox(0, "v_flipped", "Flip view horizontally"));
	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNewMenuButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

#endif

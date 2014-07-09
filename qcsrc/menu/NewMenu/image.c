#ifdef INTERFACE
CLASS(NewMenuImage) EXTENDS(Image)
	METHOD(NewMenuImage, configureNewMenuImage, void(entity, string, float))
ENDCLASS(NewMenuImage)
entity makeNewMenuImage(string theImage, float theAspect);
#endif

#ifdef IMPLEMENTATION
entity makeNewMenuImage(string theImage, float theAspect)
{
	entity me;
	me = spawnNewMenuImage();
	me.configureNewMenuImage(me, theImage, theAspect);
	return me;
}
void configureNewMenuImageNewMenuImage(entity me, string theImage, float theAspect)
{
	me.configureImage(me, theImage);
	if(theAspect < 0) // use image aspect
	{
		vector sz;
		sz = draw_PictureSize(theImage);
		me.forcedAspect = sz_x / sz_y;
	}
	else
		me.forcedAspect = theAspect;
}
#endif

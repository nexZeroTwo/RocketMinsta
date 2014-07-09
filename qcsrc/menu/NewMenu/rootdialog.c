#ifdef INTERFACE
CLASS(NewMenuRootDialog) EXTENDS(NewMenuDialog)
	// still to be customized by user
	/*
	ATTRIB(NewMenuDialog, closable, float, 1)
	ATTRIB(NewMenuDialog, title, string, "Form1") // ;)
	ATTRIB(NewMenuDialog, color, vector, '1 0.5 1')
	ATTRIB(NewMenuDialog, intendedWidth, float, 0)
	ATTRIB(NewMenuDialog, rows, float, 3)
	ATTRIB(NewMenuDialog, columns, float, 2)
	*/
	METHOD(NewMenuRootDialog, close, void(entity))
ENDCLASS(NewMenuRootDialog)
#endif

#ifdef IMPLEMENTATION
void closeNewMenuRootDialog(entity me)
{
	m_goto(string_null);
}
#endif

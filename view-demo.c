/*
compile with vbcc:
vc +kick13 view-demo.c -o view-demo
*/

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <graphics/view.h>
#include <hardware/custom.h>
#include <stdio.h>


void OpenLibs();
void Error(char *String);
void CloseLibs();
struct View *MakeView();
struct ViewPort *MakeViewPort();
struct BitMap *MakeBitMap();
struct RastPort *MakeRastPort();
struct RasInfo *MakeRasInfo();

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;

#define custom ((struct Custom *) (0xDFF000))

int width = 320;
int height = 256;
int depth = 5;

static UWORD MyColors[] =
{	0x0000,0x0111,0x0222,0x0333,0x0444,0x0555,0x0666,0x0777,
	0x0888,0x0999,0x0aaa,0x0bbb,0x0ccc,0x0ddd,0x0eee,0x0fff,
	0x000f,0x002f,0x004f,0x006f,0x008f,0x00af,0x00cf,0x00ef,
	0x00f0,0x00f2,0x00f4,0x00f6,0x00f8,0x00fa,0x00fc,0x00fe
};

int main()
{
	struct View *ViewLord;
	int i;
	UWORD value;
	UBYTE pen;
	SHORT x1, x2, y1, y2;
	struct View *MyView;
	struct ViewPort *MyViewPort;
	struct BitMap *MyBitMap;
	struct RastPort *MyRastPort;
	struct RasInfo *MyRasInfo;
	struct ColorMap *MyColorMap;

	OpenLibs();
	
	if (MyView = MakeView())
	{
		if (MyViewPort = MakeViewPort())
		{
			if (MyBitMap = MakeBitMap())
			{
				if (MyRastPort = MakeRastPort())
				{
					if (MyRasInfo = MakeRasInfo())
					{
						for (i=0; i<depth; i++)
							MyBitMap->Planes[i] = AllocMem(width*height, MEMF_CHIP|MEMF_CLEAR);
						
						ViewLord = ViewAddress();
						
						MyViewPort->DWidth = width;
						MyViewPort->DHeight = height;
						MyView->ViewPort = MyViewPort;
						MyViewPort->RasInfo = MyRasInfo;
						MyRasInfo->BitMap = MyBitMap;
						MyRastPort->BitMap = MyBitMap;
						
						MyColorMap = GetColorMap(32);
						
						MyViewPort->ColorMap = MyColorMap;
						
						MakeVPort(MyView, MyViewPort);
						MrgCop(MyView);
						
						LoadRGB4(MyViewPort, MyColors, 32);
						
						LoadView(MyView);
						
						pen = 15;
						x1 = 85;
						y1 = 53;
						x2 = 235;
						y2 = 203;
						do
						{
							SetAPen(MyRastPort, pen);
							RectFill(MyRastPort, x1, y1, x2, y2);
							x2 = x2 - 10;
							y2 = y2 - 10;
							pen = pen - 1;
						} while (pen);
						
						do value = custom->potinp; while (value&1024);
						
						LoadView(ViewLord);
						
						FreeColorMap(MyColorMap);
						FreeVPortCopLists(MyViewPort);
						FreeCprList(MyView->LOFCprList);
						
						FreeMem(MyRasInfo,sizeof(struct RasInfo));
						FreeMem(MyRastPort,sizeof(struct RastPort));
						FreeMem(MyViewPort,sizeof(struct ViewPort));
						FreeMem(MyView,sizeof(struct View));
						for (i=0; i<depth; i++)
							FreeMem(MyBitMap->Planes[i],width*height);
						FreeMem(MyBitMap,sizeof(struct BitMap));
						
					}
				}
			}
		}
	}
	
	CloseLibs();
}

void OpenLibs()
{
	if (!(GfxBase = (struct GfxBase *)OpenLibrary ("graphics.library", 0L)))
		Error ("Could not open graphics.library\n");
		
	if (!(IntuitionBase = (struct IntuitionBase *)OpenLibrary ("intuition.library", 0L)))
		Error ("Could not open intuition.library\n");
}

void Error(char *String)
{
	printf(String);
	CloseLibs();
	exit(0);
}

void CloseLibs()
{
	if (IntuitionBase) CloseLibrary ((struct Library *) IntuitionBase);
	if (GfxBase) CloseLibrary ((struct Library *) GfxBase);
}

struct View *MakeView()
{
	struct View *v;
	
	if (v = AllocMem(sizeof(struct View), MEMF_CHIP|MEMF_CLEAR))
	{
		InitView(v);
		return(v);
	}
	else
	{
		printf("Could not create View\n");
		return(NULL);
	}
}

struct ViewPort *MakeViewPort()
{
	struct ViewPort *vp;
	
	if (vp = AllocMem(sizeof(struct ViewPort), MEMF_CHIP|MEMF_CLEAR))
	{
		InitVPort(vp);
		return(vp);
	}
	else
	{
		printf("Could not create ViewPort\n");
		return(NULL);
	}
}

struct BitMap *MakeBitMap()
{
	struct BitMap *bm;
	
	if (bm = AllocMem(sizeof(struct BitMap), MEMF_CHIP|MEMF_CLEAR))
	{
		InitBitMap(bm, depth, width, height);
		return(bm);
	}
	else
	{
		printf("Could not create BitMap\n");
		return(NULL);
	}
}

struct RastPort *MakeRastPort()
{
	struct RastPort *rp;
	
	if (rp = AllocMem(sizeof(struct RastPort), MEMF_CHIP|MEMF_CLEAR))
	{
		InitRastPort(rp);
		return(rp);
	}
	else
	{
		printf("Could not create RastPort\n");
		return(NULL);
	}
}

struct RasInfo *MakeRasInfo()
{
	struct RasInfo *ri;
	
	if (ri = AllocMem(sizeof(struct RasInfo), MEMF_CHIP|MEMF_CLEAR))
	{
		return(ri);
	}
	else
	{
		printf("Could not create RasInfo\n");
		return(NULL);
	}
}


	
	
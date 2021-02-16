_SysBase		=		$04

; Exec
OpenLibrary		=		-552
CloseLibrary		=		-414
AllocMem		=		-198
FreeMem			=		-210

; Gfx
DrawEllipse		=		-180
LoadRGB4		=		-192
InitRastPort		=		-198
InitVPort		=		-204
MrgCop			=		-210
MakeVPort		=		-216
LoadView		=		-222
SetRast			=		-234
RectFill		=		-306
SetAPen			=		-342
SetBPen			=		-348
InitView		=		-360
InitBitMap		=		-390
FreeVPortCopLists	=		-540
FreeCprList		=		-564
GetColorMap		=		-570
FreeColorMap		=		-576

; Intuition
ViewAddress		=		-294

bm_Planes		=		8

v_ViewPort		=		0
v_LOFCprList		=		4

vp_ColorMap		=		4
vp_DWidth		=		24
vp_DHeight		=		26
vp_RasInfo		=		36

ri_BitMap		=		4

rp_BitMap		=		4

MEMF_CHIP		=		2
MEMF_CLEAR		=		$10000

POTINP			=		$dff016

width			=		320
height			=		256
depth			=		5

;
; BEGIN
;
			move.l		_SysBase,a6
			lea 		gfxname,a1		; graphics.library
			clr.l 		d0
			jsr		OpenLibrary(a6)
			move.l 		d0,_GfxBase	

			move.l		_SysBase,a6
			lea 		intuiname,a1		; intuition.library
			clr.l 		d0
			jsr		OpenLibrary(a6)
			move.l 		d0,_IntuiBase	

			move.l		#width,d0
			lsr.l		#3,d0
			move.l		#height,d1
			mulu		d1,d0
			move.l		d0,BitplaneOffset
			move.l		#depth,d1
			mulu		d1,d0			; width * height * depth
			move.l		d0,BitplaneMemory
			move.l		#MEMF_CHIP!MEMF_CLEAR,d1
			move.l		_SysBase,a6
			jsr		AllocMem(a6)		; allocate memory for bitmap
			move.l		d0,BitplanesPtr
			
			move.l		_SysBase,a6
			move.l		#210,d0
			move.l		#MEMF_CHIP!MEMF_CLEAR,d1
			jsr		AllocMem(a6)		; allocate memory for structures
			move.l		d0,MyViewPtr
			add.l		#18,d0
			move.l		d0,MyViewPortPtr
			add.l		#40,d0
			move.l		d0,MyBitMapPtr
			add.l		#40,d0
			move.l		d0,MyRastPortPtr
			add.l		#100,d0
			move.l		d0,MyRasInfoPtr
			
			move.l 		_IntuiBase,a6
			jsr		ViewAddress(a6)		; save old view
			move.l		d0,ViewLord
			
			move.l		_GfxBase,a6
			move.l		MyViewPtr,a0
			jsr		InitView(a6)		; initialize new view structure
			
			move.l		_GfxBase,a6
			move.l		MyViewPortPtr,a0
			jsr		InitVPort(a6)		; initialize new viewport structure
			
			move.l		_GfxBase,a6
			move.l		MyBitMapPtr,a0
			move.l		#depth,d0
			move.l		#width,d1
			move.l		#height,d2
			jsr		InitBitMap(a6)		; initialize new bitmap structure
			
			move.l		BitplanesPtr,a0
			move.l		BitplaneOffset,d0
			move.l		#depth,d1
			subq		#1,d1
			move.l		MyBitMapPtr,a1
			add.l		#bm_Planes,a1
BitplaneLoop		move.l		a0,(a1)+		; set Bitplane pointers in bitmap structure
			add.l		d0,a0
			dbra		d1,BitplaneLoop
			
			move.l		_GfxBase,a6
			move.l		MyRastPortPtr,a1
			jsr		InitRastPort(a6)	; initialize new rastport structure
			
			move.l		MyViewPtr,a0
			move.l		MyViewPortPtr,a1
			move.w		#width,vp_DWidth(a1)	; set width of viewport
			move.w		#height,vp_DHeight(a1)	; set height of viewport
			move.l		a1,v_ViewPort(a0)	; set viewport pointer in view structure
			
			move.l		MyRasInfoPtr,a0
			move.l		a0,vp_RasInfo(a1)	; set rasinfo pointer in viewport structure
			
			move.l		MyBitMapPtr,a1
			move.l		a1,ri_BitMap(a0)	; set bitmap pointer in rasinfo structure
			
			move.l		MyRastPortPtr,a0
			move.l		a1,rp_BitMap(a0)	; set bitmap pointer in rastport structure
			
			move.l		_GfxBase,a6
			move.l		#32,d0
			jsr		GetColorMap(a6)		; create colormap structure
			move.l		d0,ColorMapPtr
			
			move.l		MyViewPortPtr,a1
			move.l		d0,vp_ColorMap(a1)	; set colormap pointer in viewport structure
			
			move.l		_GfxBase,a6
			move.l		MyViewPtr,a0
			jsr		MakeVPort(a6)		; derive copper lists of the viewport
			
			move.l		_GfxBase,a6
			move.l		MyViewPtr,a1
			jsr		MrgCop(a6)		; merge all copper lists
			
			move.l		_GfxBase,a6
			move.l		MyViewPortPtr,a0
			lea		MyColors,a1
			move.l		#32,d0
			jsr		LoadRGB4(a6)		; load 32 color values into colormap
			
			move.l		_GfxBase,a6
			move.l		MyViewPtr,a1
			jsr		LoadView(a6)		; activate copper list of view
			
			move.l		_GfxBase,a6
			move.l		MyRastPortPtr,a1
			move.l		#15,d5
			move.l		#235,d2
			move.l		#203,d3
drawloop		move.l		d5,d0
			jsr		SetAPen(a6)
			move.l		#85,d0
			move.l		#53,d1
			movem.l		d2-d3/a1,-(sp)
			jsr		RectFill(a6)		; draw some filled rectangles
			movem.l		(sp)+,d2-d3/a1
			sub.l		#10,d2
			sub.l		#10,d3
			dbra		d5,drawloop
			
waitbutton		btst.b		#$0a,POTINP		; test for right mouse button down
			bne		waitbutton	
			
			move.l		_GfxBase,a6
			move.l		ViewLord,a1
			jsr		LoadView(a6)		; restore old View
			
			move.l		_GfxBase,a6
			move.l		ColorMapPtr,a0
			jsr		FreeColorMap(a6)	; free own colormap
			
			move.l		_GfxBase,a6
			move.l		MyViewPortPtr,a0
			jsr		FreeVPortCopLists(a6)	; free all copper lists of viewport
			
			move.l		_GfxBase,a6
			move.l		MyViewPtr,a1
			move.l		v_LOFCprList(a1),a0
			jsr		FreeCprList(a6)		; free copper list of MrgCop routine
			
			move.l		_SysBase,a6
			move.l		MyViewPtr,a1
			move.l		#210,d0
			jsr		FreeMem(a6)		; free allocated memory for structures
			
			move.l		_SysBase,a6
			move.l		BitplanesPtr,a1
			move.l		BitplaneMemory,d0
			jsr		FreeMem(a6)		; free allocated bitmap memory
			
			move.l		_SysBase,a6
			move.l		_GfxBase,a1
			jsr		CloseLibrary(a6)	; close graphics.library
			
			move.l		_SysBase,a6
			move.l 		_IntuiBase,a1
			jsr		CloseLibrary(a6)	; close intuition.library
			
			rts
			

; --- DATA ---
gfxname			dc.b 		"graphics.library",0
intuiname		dc.b 		"intuition.library",0
			cnop		0,2
			
_GfxBase		dc.l 		0
_IntuiBase		dc.l 		0

BitplaneOffset		dc.l		0
BitplaneMemory		dc.l		0
BitplanesPtr		dc.l		0
ViewLord		dc.l		0
ColorMapPtr		dc.l		0

MyViewPtr		dc.l		0
MyViewPortPtr		dc.l		0
MyBitMapPtr		dc.l 		0
MyRastPortPtr		dc.l		0
MyRasInfoPtr		dc.l		0

MyColors		dc.w		$0000,$0111,$0222,$0333,$0444,$0555,$0666,$0777
			dc.w		$0888,$0999,$0aaa,$0bbb,$0ccc,$0ddd,$0eee,$0fff
			dc.w		$000f,$002f,$004f,$006f,$008f,$00af,$00cf,$00ef
			dc.w		$00f0,$00f2,$00f4,$00f6,$00f8,$00fa,$00fc,$00fe

			
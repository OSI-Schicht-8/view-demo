# view-demo
Example for creating a display using View, ViewPort, BitMap and RastPort

## description
+ open graphics and intuition library
+ allocate memory for a bitmap (320 x 256 / 5 bitplanes)
+ allocate memory for View, ViewPort, BitMap, RastPort and RasInfo structures
+ save old View structure
+ initialize new View structure
+ initialize new ViewPort structure
+ initialize new BitMap structure
+ set pointers to all 5 bitplanes in BitMap structure
+ initialize new RastPort structure
+ set width and height of the display segment in the ViewPort structure (vp_DWidth and vp_DHeight)
+ set pointer to the ViewPort structure in the View structure (v_ViewPort)
+ set pointer to the RasInfo structure in the ViewPort structure (vp_RasInfo)
+ set pointer to the BitMap structure in the RasInfo structure (ri_BitMap)
+ set pointer to the BitMap structure in the RastPort structure (rp_BitMap)
+ create a ColorMap structure with 32 colors
+ set pointer to the ColorMap structure in the ViewPort structure (vp_ColorMap)
+ MakeVPort() constructs intermediate copper list and puts pointer in viewport
+ MrgCop() merges intermediate Copper lists to a "real" Copper list
+ LoadRGB4() loads color values from a table and updates the Copper lists
+ LoadView() uses the Copper lists to create the display
+ draw some filled rectangles using RectFill()
+ wait for right mouse button (bit 10 in POTINP register)
+ restore old saved View with LoadView()
+ free the ColorMap structure using FreeColorMap()
+ FreeVPortCopLists() deallocates the intermediate Copper lists from the ViewPort structure
+ FreeCprList deallocates the hardware Copper list (v_LOFCprList)
+ free allocated memory for structures
+ close libraries

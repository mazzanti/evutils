unit eVupengl;

interface

uses windows, opengl, textures, classes, sysutils;

procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;
function glCreateWnd(Width, Height: Integer; PixelDepth: Integer; wnd: thandle): Boolean;
procedure glDraw();
procedure glKillWnd();
procedure loadtexture(s: string; var t: GLuint; res: Boolean);


var
  VidTextures: array[0..5] of GLuint;
  texBackground: GLuint;
  texFont: GLuint;

  ListaCredits: tstringlist;

implementation

var
  h_Wnd: HWND; // Global window handle
  h_DC: HDC; // Global device context
  h_RC: HGLRC; // OpenGL rendering context
  xAngle, yAngle: glFloat;
  xSpeed, ySpeed: glFloat;
  glz: glFloat;
  gltestoy: glFloat;


procedure loadtexture(s: string; var t: GLuint; res: Boolean);
begin
  textures.loadtexture(s, t, res)
end;

{------------------------------------------------------------------}
{  Handle window resize                                            }
{------------------------------------------------------------------}

procedure glResizeWnd(Width, Height: Integer);
begin
  if (Height = 0) then // prevent divide by zero exception
    Height := 1;
  glViewport(0, 0, Width, Height); // Set the viewport for the OpenGL window
  glMatrixMode(GL_PROJECTION); // Change Matrix Mode to Projection
  glLoadIdentity(); // Reset View
  gluPerspective(45.0, Width / Height, 1.0, 100.0); // Do the perspective calculations. Last value = max clipping depth

  glMatrixMode(GL_MODELVIEW); // Return to the modelview matrix
  glLoadIdentity(); // Reset View
end;

{------------------------------------------------------------------}
{  Initialise OpenGL                                               }
{------------------------------------------------------------------}

procedure glInit();
begin
  glClearColor(0.0, 0.0, 0.0, 0.0); // Black Background
  glShadeModel(GL_SMOOTH); // Enables Smooth Color Shading
  glClearDepth(1.0); // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST); // Enable Depth Buffer
  glDepthFunc(GL_LEQUAL); // The Type Of Depth Test To Do
  glEnable(GL_TEXTURE_2D);

  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 0.4);

  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST); //Realy Nice perspective calculations
  xSpeed := 0.55;
  ySpeed := 0.90;
  gltestoy := -(1.0 + (0.16 * ListaCredits.count));
  glz := 0.0;
end;

function glCreateWnd(Width, Height: Integer; PixelDepth: Integer; wnd: thandle): Boolean;
var
  PixelFormat: GLuint; // Settings for the OpenGL rendering
  pfd: TPIXELFORMATDESCRIPTOR; // Settings for the OpenGL window
begin
  // Try to get a device context
  h_Wnd := wnd;
  h_DC := GetDC(h_Wnd);
  if (h_DC = 0) then
  begin
    MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Settings for the OpenGL window
  with pfd do
  begin
    nSize := SizeOf(TPIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
    nVersion := 1; // The version of this data structure
    dwFlags := PFD_DRAW_TO_WINDOW // Buffer supports drawing to window
      or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
      or PFD_DOUBLEBUFFER; // Supports double buffering
    iPixelType := PFD_TYPE_RGBA; // RGBA color format
    cColorBits := PixelDepth; // OpenGL color depth
    cRedBits := 0; // Number of red bitplanes
    cRedShift := 0; // Shift count for red bitplanes
    cGreenBits := 0; // Number of green bitplanes
    cGreenShift := 0; // Shift count for green bitplanes
    cBlueBits := 0; // Number of blue bitplanes
    cBlueShift := 0; // Shift count for blue bitplanes
    cAlphaBits := 0; // Not supported
    cAlphaShift := 0; // Not supported
    cAccumBits := 0; // No accumulation buffer
    cAccumRedBits := 0; // Number of red bits in a-buffer
    cAccumGreenBits := 0; // Number of green bits in a-buffer
    cAccumBlueBits := 0; // Number of blue bits in a-buffer
    cAccumAlphaBits := 0; // Number of alpha bits in a-buffer
    cDepthBits := 16; // Specifies the depth of the depth buffer
    cStencilBits := 0; // Turn off stencil buffer
    cAuxBuffers := 0; // Not supported
    iLayerType := PFD_MAIN_PLANE; // Ignored
    bReserved := 0; // Number of overlay and underlay planes
    dwLayerMask := 0; // Ignored
    dwVisibleMask := 0; // Transparent color of underlay plane
    dwDamageMask := 0; // Ignored
  end;

  // Attempts to find the pixel format supported by a device context that is the best match to a given pixel format specification.
  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Sets the specified device context's pixel format to the format specified by the PixelFormat.

  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Create a OpenGL rendering context
  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  // Makes the specified OpenGL rendering context the calling thread's current rendering context
  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Result := False;
    Exit;
  end;

  SetTimer(h_Wnd, 1, 1000, nil);

  // Ensure the OpenGL window is resized properly
  glResizeWnd(Width, Height);
  glInit();


  Result := True;
end;

{---------------------------------------------------------------------}
{  Properly destroys the window created at startup (no memory leaks)  }
{---------------------------------------------------------------------}

procedure glKillWnd();
begin
  if h_Wnd <> 0 then
  begin
  // Makes current rendering context not current, and releases the device
  // context that is used by the rendering context.
    if (not wglMakeCurrent(h_DC, 0)) then
      MessageBox(0, 'Release of DC and RC failed!', 'Error', MB_OK or MB_ICONERROR);

  // Attempts to delete the rendering context
    if (not wglDeleteContext(h_RC)) then
    begin
      MessageBox(0, 'Release of rendering context failed!', 'Error', MB_OK or MB_ICONERROR);
      h_RC := 0;
    end;

  // Attemps to release the device context
    if ((h_DC = 1) and (ReleaseDC(h_Wnd, h_DC) <> 0)) then
    begin
      MessageBox(0, 'Release of device context failed!', 'Error', MB_OK or MB_ICONERROR);
      h_DC := 0;
    end;
    h_Wnd := 0;
  end;
end;


procedure glImgWrite(strText: string);
var I, intAsciiCode: integer;
  imgcharWidth: glFloat;
  imgcharPosX, riga: glFloat;
  const
    mx:glfloat=0.070;
    spaziatura:glfloat=0.09;
//  imgcharPosY: glFloat;
begin

  imgcharWidth := 0.062;
  //strText := UpperCase(strText);

  for I := 1 to length(strText) do
  begin
//    if ord(strText[I]) > 31 then //only handle 66 chars
    begin
      intAsciiCode := ord(strText[I]) - 32;
      riga:=intasciicode div 16;
      intasciicode:=intasciicode mod 16;
      imgcharPosX := length(strText) / 2 * spaziatura - length(strText) * spaziatura + (I - 1) * spaziatura; // Find the character position from the origin [0.0 , 0.0 , 0.0]  to center the text
      glBegin(GL_QUADS);
//      imgcharPosX := 0.0;

      glTexCoord2f(imgcharWidth * intAsciiCode, riga*imgcharWidth);
      glVertex3f(-mx + imgcharPosX, mx, 0.0);

      glTexCoord2f(imgcharWidth * intAsciiCode + imgcharWidth, riga*imgcharWidth);
      glVertex3f(mx + imgcharPosX, mx, 0.0);

      glTexCoord2f(imgcharWidth * intAsciiCode + imgcharWidth, imgcharWidth+riga*imgcharWidth);
      glVertex3f(mx + imgcharPosX, -mx, 0.0);

      glTexCoord2f(imgcharWidth * intAsciiCode, imgcharWidth+riga*imgcharWidth);
      glVertex3f(-mx + imgcharPosX, -mx, 0.0);
      glEnd;
    end;
  end;
end;


{------------------------------------------------------------------}
{  Function to draw the actual scene                               }
{------------------------------------------------------------------}

procedure glDraw();
var
  I: Integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // Clear The Screen And The Depth Buffer

  glLoadIdentity(); // Reset The View
  glTranslatef(0.0, 0.0, -12);
  glBindTexture(GL_TEXTURE_2D, texBackground); // Bind the Texture to the object
  glColor3f(1.0, 1.0, 1.0);
  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 0.0); glVertex3f(-7.6, -7.6, 0);
  glTexCoord2f(1.0, 0.0); glVertex3f(7.6, -7.6, 0);
  glTexCoord2f(1.0, 1.0); glVertex3f(7.6, 7.6, 0);
  glTexCoord2f(0.0, 1.0); glVertex3f(-7.6, 7.6, 0);
  glEnd();

  glLoadIdentity(); // Reset The View
  glTranslatef(0.0, gltestoy, -2.2);
  for I := ListaCredits.count - 1 downto 0 do
  begin
  glBindTexture(GL_TEXTURE_2D, texFont); // Bind the Texture to the object
  glTranslatef(0.0, 0.16, 0.0);
  glColor3f(1.0*cos(i+gltestoy),1.0*sin(i-gltestoy),1.0-0.5*cos(gltestoy+i));
  //glColor3f(-1.0 * cos(3 * gltestoy), 1.0 * sin(3 * gltestoy)*cos(gltestoy), 1.0 );//- 0.5 * cos( gltestoy));
    glImgWrite(ListaCredits[I]);
  end;

  gltestoy := gltestoy + 0.006;

  if gltestoy > 1 then
    gltestoy := -(1.0 + (0.16 * ListaCredits.count));

  glColor3f(1.0, 1.0, 1.0);
  glLoadIdentity(); // Reset The View
  glTranslatef(0, 0, -5 + 1.2 * sin(glz));
  glz := glz + 0.01;

  glRotatef(xAngle, 1, 0, 0);
  glRotatef(yAngle, 0, 1, 0);

  // Front Face
  glBindTexture(GL_TEXTURE_2D, VidTextures[0]);
  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, 1.0);
  glTexCoord2f(1.0, 0.0); glVertex3f(1.0, -1.0, 1.0);
  glTexCoord2f(1.0, 1.0); glVertex3f(1.0, 1.0, 1.0);
  glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, 1.0);
  glEnd();
    // Back Face
  glBindTexture(GL_TEXTURE_2D, VidTextures[1]);
  glBegin(GL_QUADS);
  glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
  glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, 1.0, -1.0);
  glTexCoord2f(0.0, 1.0); glVertex3f(1.0, 1.0, -1.0);
  glTexCoord2f(0.0, 0.0); glVertex3f(1.0, -1.0, -1.0);
  glEnd();
      // Top Face
  glBindTexture(GL_TEXTURE_2D, VidTextures[2]);
  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, -1.0);
  glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, 1.0, 1.0);
  glTexCoord2f(1.0, 0.0); glVertex3f(1.0, 1.0, 1.0);
  glTexCoord2f(1.0, 1.0); glVertex3f(1.0, 1.0, -1.0);
  glEnd();
    // Bottom Face
  glBindTexture(GL_TEXTURE_2D, VidTextures[3]);
  glBegin(GL_QUADS);
  glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, -1.0, -1.0);
  glTexCoord2f(0.0, 1.0); glVertex3f(1.0, -1.0, -1.0);
  glTexCoord2f(0.0, 0.0); glVertex3f(1.0, -1.0, 1.0);
  glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, 1.0);
  glEnd();
      // Right face
  glBindTexture(GL_TEXTURE_2D, VidTextures[4]);
  glBegin(GL_QUADS);
  glTexCoord2f(1.0, 0.0); glVertex3f(1.0, -1.0, -1.0);
  glTexCoord2f(1.0, 1.0); glVertex3f(1.0, 1.0, -1.0);
  glTexCoord2f(0.0, 1.0); glVertex3f(1.0, 1.0, 1.0);
  glTexCoord2f(0.0, 0.0); glVertex3f(1.0, -1.0, 1.0);
  glEnd();
    // Left Face
  glBindTexture(GL_TEXTURE_2D, VidTextures[5]);
  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 0.0); glVertex3f(-1.0, -1.0, -1.0);
  glTexCoord2f(1.0, 0.0); glVertex3f(-1.0, -1.0, 1.0);
  glTexCoord2f(1.0, 1.0); glVertex3f(-1.0, 1.0, 1.0);
  glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, -1.0);
  glEnd();

  xAngle := xAngle + xSpeed;
  yAngle := yAngle + ySpeed;
  SwapBuffers(h_DC);
end;




end.


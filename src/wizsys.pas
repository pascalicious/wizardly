unit wizsys;
{*********************************************************************}
{        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE                  }
{                Version 2, December 2004                             }
{     Copyright (C) 2017 Rickard "Rickmeister" Isaksson               }
{               rickmeister@programmer.net                            }
{                                                                     }
{ Everyone is permitted to copy and distribute verbatim or modified   }
{ copies of this license document, and changing it is allowed as long }
{ as the name is changed.                                             }
{                                                                     }
{            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE              }
{   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION   }
{                                                                     }
{  0. You just DO WHAT THE FUCK YOU WANT TO.                          }
{*********************************************************************}
{$MODE OBJFPC}
{$LONGSTRINGS ON}
{$SCOPEDENUMS ON}
{$IFDEF DEBUG}
  {$ASSERTIONS ON}
{$ENDIF}

interface

uses
Classes, SysUtils, SDL2, wizglobals;

type
  TSDLColor = record
    r, g, b, a : byte;
  end;

  TWizWindow = class
    sdlWindow : PSDL_Window;
    sdlRenderer : PSDL_Renderer;
    viewPort : TSDL_Rect;
    viewPortTexture : PSDL_Texture;
    sdlClearColor : TSDLColor;
    windowWidth : integer;
    windowHeight : integer;
    renderWidth : integer;
    renderHeight : integer;
    windowFullscreen : boolean;
    windowCaption : AnsiString;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Update;
  end;
implementation
{>> TWizWindow <<}
procedure TWizWindow.Clear;
begin
  SDL_SetRenderDrawColor(sdlRenderer,sdlClearColor.r, sdlClearColor.g, sdlClearColor.b, sdlClearColor.a);
  SDL_RenderClear(sdlRenderer);
end;
procedure TWizWindow.Update;
begin
  {$IFDEF DEBUG}
  SDL_SetRenderDrawColor(sdlRenderer,0,255,0,64);
  SDL_RenderDrawRect(sdlRenderer,@viewPort);
  {$ENDIF}
  SDL_RenderPresent(sdlRenderer);
end;
destructor TWizWindow.Destroy;
begin
  if Assigned(sdlRenderer) then SDL_DestroyRenderer(sdlRenderer);
  if Assigned(sdlWindow) then SDL_DestroyWindow(sdlWindow);
end;

constructor TWizWindow.Create;
var
  wstyle : cardinal;
  vpw, vph : integer;
begin
  SDL_Init(SDL_INIT_EVERYTHING);
  windowWidth := TWizSettings.windowWidth;
  windowHeight := TWizSettings.windowHeight;
  renderWidth := TWizSettings.renderWidth;
  renderHeight := TWizSettings.renderHeight;
  windowCaption := 'Wizardly';
  windowFullscreen := TWizSettings.fullscreen;
  if windowFullscreen then wstyle := SDL_WINDOW_FULLSCREEN_DESKTOP else wstyle:=0;
  with sdlClearColor do
  begin
    r := 0;
    g := 0;
    b := 0;
    a := 255;
  end;
  sdlWindow := SDL_CreateWindow(pAnsiChar(windowCaption),SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, windowWidth, windowHeight, wstyle);
  Assert(sdlWindow <> nil, SDL_GetError);
  sdlRenderer := SDL_CreateRenderer(sdlWindow, -1, SDL_RENDERER_ACCELERATED or SDL_RENDERER_TARGETTEXTURE);
  Assert(sdlRenderer <> nil, SDL_GetError);
  SDL_RenderSetLogicalSize(sdlRenderer,renderWidth, renderHeight);
  viewPort.x := TWizSettings.viewportLeft;
  viewPort.y := TWizSettings.viewportTop;
  viewPort.w := TWizSettings.viewportWidth;
  viewPort.h := TWizSettings.viewportHeight;
  vpw := TWizSettings.vpTextureWidth;
  vph := TWizSettings.vpTextureHeight;
  viewPortTexture := SDL_CreateTexture(sdlRenderer,SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET,vpw,vph);
  Assert(viewPortTexture <> nil, SDL_GetError);
end;
{<< TWizWindow >>}
end.

{ vim: set ts=2 sw=2 tw=0  }

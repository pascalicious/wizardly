unit wizobj;
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
  Classes, SysUtils, SDL2, wizglobals, wiztex;

type
  TWizAnimator = class
  end;

  { TWizSprite }

  TWizSprite = class
    gridX, gridY : integer;
    rect : TSDL_Rect;
    texture : PSDL_Texture;
    constructor Create(x,y : integer);
  end;

  { TWizPlayer }

  TWizPlayer = class
    texture : PSDL_Texture;
    frame : array [0..3] of TSDL_Rect;
    rect : PSDL_Rect;
    origo : TSDL_Point;
    x, y : double;
    offx, offy : integer;
    w,h : integer;
    tx,ty : integer; // map coord
    gx,gy : integer; // grid coord
    maxx,maxy : integer;
    health : integer;
    keys : integer;
    gold : integer;
    constructor Create();
    procedure Move(dx,dy : integer);
    procedure MoveTo(posx,posy : integer);
  end;

var
  GlobalPlayer : TWizPlayer;

implementation

{ TWizPlayer }

constructor TWizPlayer.Create();
var
  i : integer;
begin
  texture:=TWizTextureManager.GetInstance.GetSDLTexture('player.png');
  w:=TWizSettings.playerWidth;
  h:=TWizSettings.playerHeight;
  for i:=0 to 3 do
  begin
    frame[i].w:=w;
    frame[i].h:=h;
    frame[i].x:=i*w;
    frame[i].y:=0;
  end;
  rect:=@frame[2];
  offx:=2;
  offy:=2;
end;

procedure TWizPlayer.Move(dx, dy: integer);
begin
{  x:=rect^.x;
  y:=rect^.y;
  x:=x+dx;
  y:=y+dy;
  if x < 0 then x:=0;
  if y<0 then y:=0;
  rect^.x:=round(x);
  rect^.y:=round(y);
  origo.x:=origo.x+round(x);
  origo.y:=origo.y+round(y);
{$IFDEF DEBUG}
  writeln('x: ', x:4:3, ' y: ', y:4:3);
  writeln('origo at tile: ',tx, ', ', ty);
{$ENDIF}
}
  tx:=tx+round(dx);
  ty:=ty+round(dy);
end;

procedure TWizPlayer.MoveTo(posx, posy: integer);
begin
  tx:=posx; ty:=posy;
  {$IFDEF DEBUG}
  writeln('player ported to ', tx,', ', ty);
  {$ENDIF}
end;


{ TWizSprite }

constructor TWizSprite.Create(x, y: integer);
begin

end;

end.
{ vim: set ts=2 sw=2 tw=0  }


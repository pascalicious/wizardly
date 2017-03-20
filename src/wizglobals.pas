unit wizglobals;
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
  Classes, SysUtils, IniFiles, SDL2;
const
  ITEM_CHEST=65;
  ITEM_COIN=66;
  ITEM_KEY=67;
  ITEM_FOOD=68;
  ITEM_POTION=69;

  TRIGGER_WALL=81;
  TRIGGER_DANGER=82;
  TRIGGER_ENTRY=83;
  TRIGGER_ITEM=84;
  TRIGGER_SPAWN=85;
  TRIGGER_EXIT=86;
  TRIGGER_TRIG=87;
  TRIGGER_PORTAL=88;
  TRIGGER_KEY=89;

  PORTAL_DOOR1=90;
  PORTAL_DOOR2=91;
type

  { TWizSettings }

  TWizSettings = class
    class var windowWidth : integer;
    class var windowHeight : integer;
    class var renderWidth : integer;
    class var renderHeight : integer;
    class var gridWidth : integer;
    class var gridHeight : integer;
    class var tileWidth : integer;
    class var tileHeight : integer;
    class var viewportLeft : integer;
    class var viewportTop : integer;
    class var viewportWidth : integer;
    class var viewportHeight : integer;
    class var vpTextureWidth : integer;
    class var vpTextureHeight : integer;
    class var horizontalPadding : integer;
    class var verticalPadding : integer;
    class var fullscreen : boolean;
    class var debug : boolean;
    class var pathDelim : AnsiString;
    class var assetPath : AnsiString;
    // units
    class var playerHeight : integer;
    class var playerWidth : integer;
    class var movementSpeed : double;
    class var pixelMargin : integer;
    class procedure ReadSettings;
    class procedure WriteSettings;
  end;

implementation

{ TWizSettings }

class procedure TWizSettings.ReadSettings;
var
  ini : TIniFile;
  b : integer;
  centerX, centerY, left : integer;
begin
  try
    ini := TIniFile.Create('wizardly.ini');
    windowWidth:=ini.ReadInteger('system','windowWidth',960);
    windowHeight:=ini.ReadInteger('system','windowHeight',540);
    renderWidth:=ini.ReadInteger('system','renderWidth', 640);
    renderHeight:=ini.ReadInteger('system','renderHeight', 360);
    tileWidth:=ini.ReadInteger('system','tileWidth',16);
    tileHeight:=ini.ReadInteger('system','tileHeight',16);
    centerX := round(renderWidth/2);
    centerY := round(renderHeight/2);
    viewportLeft:=ini.ReadInteger('system','viewportLeft',tileWidth);
    viewportTop:=ini.ReadInteger('system','viewportTop',tileHeight);
    viewportWidth:=ini.ReadInteger('system','viewportWidth',16*tileWidth);
    viewportHeight:=ini.ReadInteger('system','viewportHeight',12*tileHeight);
    gridWidth:=ini.ReadInteger('system','gridWidth',18);
    gridHeight:=ini.ReadInteger('system','gridHeight',15);
    horizontalPadding:=round(gridWidth/2);
    verticalPadding:=round(gridHeight/2);
    vpTextureWidth:=gridWidth*tileWidth;
    vpTextureHeight:=gridHeight*tileHeight;
    b:=ini.ReadInteger('system','fullscreen',0);
    if b > 0 then fullscreen:=true else fullscreen:=false;
    b:=ini.ReadInteger('system','debug', 0);
    if b > 0 then debug:=true else fullscreen:=false;
    assetPath:=ini.ReadString('system','assetPath','assets'+pathDelim);
    // units
    playerWidth:=ini.ReadInteger('units','playerWidth',12);
    playerHeight:=ini.ReadInteger('units','playerHeight',14);
    movementSpeed:=ini.ReadFloat('units','movementSpeed',0.2);
    pixelMargin:=ini.ReadInteger('units','pixelMargin',2);
  finally
    ini.Free;
  end;
end;

class procedure TWizSettings.WriteSettings;
var
  ini : TIniFile;
  b : integer;
begin
  try
    ini := TIniFile.Create('wizardly.ini');
    ini.WriteString('system','windowWidth',IntToStr(windowWidth));
    ini.WriteString('system','windowHeight',IntToStr(windowHeight));
    ini.WriteString('system','renderWidth', IntToStr(renderWidth));
    ini.WriteString('system','renderHeight', IntToStr(renderHeight));
    ini.WriteString('system','tileWidth',IntToStr(tileWidth));
    ini.WriteString('system','tileHeight',IntToStr(tileHeight));
    ini.WriteString('system','gridWidth',IntToStr(gridWidth));
    ini.WriteString('system','gridHeight',IntToStr(gridHeight));
    ini.WriteString('system','viewportTop',IntToStr(viewportTop));
    ini.WriteString('system','viewportLeft',IntToStr(viewportLeft));
    ini.WriteString('system','viewportWidth',IntToStr(viewportWidth));
    ini.WriteString('system','viewportHeight',IntToStr(viewportHeight));
    if fullscreen then b:=1 else b:=0;
    ini.WriteString('system','fullscreen',IntToStr(b));
    if debug then b:=1 else b:=0;
    ini.WriteString('system','debug',IntToStr(b));
    ini.WriteString('system','assetPath',assetPath);
    // units
    ini.WriteInteger('units','playerWidth',playerWidth);
    ini.WriteInteger('units','playerHeight',playerHeight);
    ini.WriteFloat('units','movementSpeed',movementSpeed);
    ini.WriteInteger('units','pixelMargin', 2);
  finally
    ini.Free;
  end;
end;

initialization

TWizSettings.pathDelim := SysUtils.PathDelim;

end.
{ vim: set ts=2 sw=2 tw=0  }

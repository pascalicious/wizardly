unit wizdraw;
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
  Classes, SysUtils,SDL2, wizcore, wiztex, wizsys, wizglobals;

type

  TWizCamera = class
    wizLevel : TWizLevel;
    lvlX, lvlY : integer; //top left map coords drawn
    scrollX, scrollY : integer;
    sizeX, sizeY : integer; // Size of map
    width, height : integer; // Size of portion to draw
    renderlist : array of integer;
    constructor Create(lvl : TWizLevel);
  end;

  { TWizDraw }

  TWizDraw = class
    wizWindow : TWizWindow;
    wizLevel : TWizLevel;

  end;

implementation
{>> TWizCamera <<}
constructor TWizCamera.Create(lvl : TWizLevel);
begin
  wizlevel := lvl;
  sizeX := lvl.width;
  sizeY := lvl.height;
  SetLength(renderlist, sizeX*sizeY);
end;
{<< TWizCamera >>}


end.
{ vim: set ts=2 sw=2 tw=0  }

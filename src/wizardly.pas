program wizardly;
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

{ TODO : Add a slash screen with Lazarus/Free Pascal logo }
{ TODO : Add a title screen/main menu }
uses
  Classes, SysUtils, SDL2, wizsys, wiztex, wizmap, wizglobals, wizcore, wizobj;

var
    wiz : TWizWindow;
    tex : TWizTextureManager;
    map : TWizMap;
    level : TWizLevel;
    event : TSDL_Event;
    running : boolean;
    tr : TWizTileRenderer;
    game : TWizGame;
begin
    TWizSettings.ReadSettings;
    wiz := TWizWindow.Create;
    tex := TWizTextureManager.Create(wiz);
    tex.LoadTexture('void.png');
    game:=TWizGame.Create(wiz,'lvl1.tmx');
    game.Run;
    FreeAndNil(game);
    FreeAndNil(wiz);
    FreeAndNil(tex);
    TWizSettings.WriteSettings;
end.

{ vim: set ts=2 sw=2 tw=0  }

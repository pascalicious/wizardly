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

uses
    Classes, SysUtils, SDL2, wizsys, wiztex, wizmap, wizdraw,
wizglobals, wizcore;

var
    wiz : TWizWindow;
    tex : TWizTextureManager;
    map : TWizMap;
    draw : TWizDraw;
    level : TWizLevel;
    event : TSDL_Event;
    running : boolean;
begin
    TWizSettings.ReadSettings;
    wiz := TWizWindow.Create;
    tex := TWizTextureManager.Create(wiz);
    map := TWizMap.Create('assets/lvl1.tmx');
    level := TWizLevel.Create(map); // Create an array of tiles
    FreeAndNil(map); // Dispose the map
    running := true;
    while running do
    begin
      while SDL_PollEvent(@event) > 0 do begin
        if event.type_ = SDL_QUITEV then running := false;
      end;
      wiz.Clear;
      wiz.Update;
    end;
    FreeAndNil(wiz);
    FreeAndNil(tex);
    FreeAndNil(level);
    TWizSettings.WriteSettings;
end.

{ vim: set ts=2 sw=2 tw=0  }

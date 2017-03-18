unit wizcore;
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
    Classes, SysUtils, SDL2, wizmap, wizglobals;

type

  tWizTile = record
    texture : PSDL_Texture;
    rect : TSDL_Rect;
  end;
  pWizTile = ^tWizTile;

  tWizItem = record
    texture : PSDL_Texture;
    rect : TSDL_Rect;
    item : word;
    value : integer;
    active : boolean;
  end;
  pWizItem = ^tWizItem;

  tWizPortal = record
    texture : PSDL_Texture;
    rect : TSDL_Rect;
    portal : word;
    active : boolean;
    locked : boolean;
  end;
  pWizPortal = ^tWizPortal;

  tWizTrigger = record
    texture : PSDL_Texture; // Debug render stuff
    rect : TSDL_Rect;
    trigger : word;
    active : boolean;
  end;
  pWizTrigger = ^tWizTrigger;

  TWizCell = class
    tile : pWizTile;
    item : pWizItem;
    portal : pWizPortal;
    trigger : pWizTrigger;
    gridX, gridY : integer;
    constructor Create(x,y: integer; tl : pWizTile; it : pWizItem; po : pWizPortal; tr : pWizTrigger);
    destructor Destroy; override;
  end;

  TWizLevel = class
    cells : array of TWizCell;
    count : integer;
    width, height : integer;
    constructor Create(map : TWizMap);
    destructor Destroy; override;
  end;

implementation
{>> TWizLevel <<}
constructor TWizLevel.Create(map : TWizMap);
var
  x, y, l, t : integer;
  tile : pWizTile;
  item : pWizItem;
  portal : pWizPortal;
  trigger : pWizTrigger;
begin
  Randomize; // Seed
  l := map.w * map.h;
  width := map.w;
  height := map.h;
  SetLength(cells, l);
  count := 0; // index
  for x := 0 to map.w - 1 do
  begin
    for y := 0 to map.h - 1 do
    begin
      tile := nil;
      item := nil;
      portal := nil;
      trigger := nil;
      t := map.floormap[x,y];
      if t > 0 then
      begin
        tile := new(pWizTile);
        tile^.texture := map.tilesets[0].sdlTexture;
        tile^.rect.x := map.tilesets[0].clip[t-1].x;
        tile^.rect.y := map.tilesets[0].clip[t-1].y;
        tile^.rect.w := map.tilesets[0].clip[t-1].w;
        tile^.rect.h := map.tilesets[0].clip[t-1].h;
      end;
      t := map.itemmap[x,y];
      if t >= 65 then
      begin
        item := new(pWizItem);
        item^.active:=true;
        item^.item:=t;
        item^.texture := map.tilesets[1].sdlTexture;
        item^.rect.x := map.tilesets[1].clip[t-65].x;
        item^.rect.y := map.tilesets[1].clip[t-65].y;
        item^.rect.w := map.tilesets[1].clip[t-65].w;
        item^.rect.h := map.tilesets[1].clip[t-65].h;
        case t of
        ITEM_CHEST:
          begin
            item^.value:=Random(129)+76; // Get this numbers from ini-file for per-level values
          end;
        ITEM_COIN:
          begin
            item^.value:=Random(10)+4;
          end;
        ITEM_KEY:
          begin
            item^.value:=0;
          end;
        end;
      end;
      t := map.portalmap[x,y];
      if t >= 90 then
      begin
        portal := new(pWizPortal);
        portal^.active:=true;
        portal^.texture :=  map.tilesets[3].sdlTexture;
        portal^.rect.x := map.tilesets[3].clip[t-90].x;
        portal^.rect.y := map.tilesets[3].clip[t-90].y;
        portal^.rect.w := map.tilesets[3].clip[t-90].w;
        portal^.rect.h := map.tilesets[3].clip[t-90].h;
      end;
      t := map.triggermap[x,y];
      if t >= 81 then
      begin
        trigger := new(pWizTrigger);
        trigger^.active:=true;
        trigger^.trigger:=t;
        trigger^.texture := map.tilesets[2].sdlTexture;
        trigger^.rect.x := map.tilesets[2].clip[t-81].x;
        trigger^.rect.y := map.tilesets[2].clip[t-81].y;
        trigger^.rect.w := map.tilesets[2].clip[t-81].w;
        trigger^.rect.h := map.tilesets[2].clip[t-81].h;
      end;
      cells[count] := TWizCell.Create(x,y,tile,item,portal,trigger);
      inc(count);
    end;
  end;
  writeln('Processed ', count,' tiles');
end;
destructor TWizLevel.Destroy;
var
  i : integer;
begin
  for i := Low(cells) to High(cells) do
  begin
    if Assigned(cells[i]) then FreeAndNil(cells[i]);
  end;
end;
{<< TWizLevel >>}
{>> TWizCell <<}
constructor TWizCell.Create(x,y: integer; tl : pWizTile; it : pWizItem; po : pWizPortal; tr : pWizTrigger);
begin
  gridX := x;
  gridY := y;
  tile := tl;
  item := it;
  portal := po;
  trigger := tr;
end;

destructor TWizCell.Destroy;
begin
  if Assigned(trigger) then dispose(trigger);
  if Assigned(portal) then dispose(portal);
  if Assigned(item) then dispose(item);
  if Assigned(tile) then dispose(tile);
end;
{<< TWizCell >>}
end.
{ vim: set ts=2 sw=2 tw=0  }


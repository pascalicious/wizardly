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
    Classes, SysUtils, SDL2, wizsys, wizmap, wizglobals, wiztex, wizobj;

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
    {$IFDEF DEBUG}
    texture : PSDL_Texture; // Debug render stuff
    rect : TSDL_Rect;
    {$ENDIF}
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
    fogged : boolean;
    constructor Create(x,y: integer; tl : pWizTile; it : pWizItem; po : pWizPortal; tr : pWizTrigger);
    destructor Destroy; override;
  end;

  TWizLevel = class
    padx, pady : integer;
    cells : array of array of TWizCell;
    player : TWizPlayer;
    count : integer;
    width, height : integer;
    playerx, playery : integer;
    constructor Create(map : TWizMap);
    destructor Destroy; override;
  end;

  { TWizCamera }

  TWizCamera = class
    lens : TSDL_Rect;
    focus : TSDL_Rect;
    level : TWizLevel;
    prect : TSDL_Rect;
    offsetx, offsety : integer; { TODO : Smooth dem scrollings, mon! }
    scrollx,scrolly : integer;
    xmin, ymin : integer;
    xmax, ymax : integer;
    cx, cy, cw, ch : integer;
    x,y : integer;
    px,py : integer;
    edgeLeft,edgeRight,edgeTop,edgeBottom : boolean;
    constructor Create(lvl : TWizLevel; w,h : integer);
    procedure Update(tx, ty : integer);
    function FocusCheck:boolean;
    procedure ScrollTiles(dx, dy : integer);
  end;

  { TWizTileRenderer }

  TWizTileRenderer = class
    window : TWizWindow;
    sdlRenderer : PSDL_Renderer;
    level : TWizLevel;
    camera : TWizCamera;
    void : PSDL_Texture;
    gw, gh : integer;
    grid : array of array of TSDL_Rect;
    constructor Create(wnd : TWizWindow; lvl : TWizLevel);
    destructor Destroy; override;
    procedure Render;
    procedure RenderFog;
    procedure NewLevel(lvl : TWizLevel);
  end;

  { TWizGame }

  TWizGame = class
    level : TWizLevel;
    nextlevel : AnsiString;
    path : AnsiString;
    window : TWizWindow;
    tilerenderer : TWizTileRenderer;
    player : TWizPlayer;
    constructor Create(wnd : TWizWindow; mapname : AnsiString);
    procedure LoadNextLevel;
    procedure MovePlayer(dx,dy:integer);
    function CheckTile(cell:TWizCell): boolean;
    procedure Run;
    destructor Destroy; override;
  end;

implementation

{ TWizGame }

constructor TWizGame.Create(wnd: TWizWindow; mapname: AnsiString);
var
  map : TWizMap;
begin
  path:=TWizSettings.assetPath;
  window:=wnd;
  map:=TWizMap.Create(path+mapname);
  nextlevel:=map.next;
  level:=TWizLevel.Create(map);
  FreeAndNil(map);
  tilerenderer:=TWizTileRenderer.Create(window,level);
  player:=TWizPlayer.Create();
  player.MoveTo(level.playerx, level.playery);
  player.texture:=TWizTextureManager.GetInstance.GetSDLTexture('player.png');
  level.player:=player;
  {$IFDEF DEBUG}
  writeln('player rendering at: ', player.rect^.x, ', ', player.rect^.y,' ,', player.rect^.w,'x',player.rect^.h);
  writeln('camera rendered at: ', tilerenderer.camera.lens.x,', ', tilerenderer.camera.lens.y,', ',tilerenderer.camera.lens.w,'x',tilerenderer.camera.lens.h);
  {$ENDIF}
end;

procedure TWizGame.LoadNextLevel;
var
  map : TWizMap;
begin
  FreeAndNil(level);
  map:=TWizMap.Create(path+nextlevel);
  level:=TWizLevel.Create(map);
  FreeAndNil(map);
  level.player:=player;
  player.MoveTo(level.playerx,level.playery);
end;

procedure TWizGame.MovePlayer(dx, dy: integer);
var
  x, y : double;
  cell : TWizCell;
  tx,ty : integer;
  gx,gy : integer;
  tw,th : integer;
  pm : integer;
begin
{  x:=dx+player.x;
  y:=dx+player.y;
  cell:=level.cells[player.tx, player.ty];
  tx:=cell.gridX; // Will use this for collision tests
  ty:=cell.gridY; // against the tilemap
  tw:=TWizSettings.tileWidth;
  th:=TWizSettings.tileHeight;
  pm:=TWizSettings.pixelMargin;
  gx:=round(player.x/16);
  gy:=round(player.y/16);
  writeln('Player grid position: ', gx,', ',gy);
  if dx < 0 then
  begin // Move left
    cell:=level.cells[tx-1,ty]; // Grab the targeted cell
    // There is no collision points, just a collision flag
    // Surround tile with a rect. As we know the player position
    // it's easy to calculate the position and dimension of the
    // adjacent tiles
    if (round(x) <= gx*16-pm) and Assigned(cell.trigger)
    and (cell.trigger^.trigger = TRIGGER_WALL)
    then dx:=0;
  end;

  if dx > 0 then
  begin // Move right
    cell:=level.cells[tx+1,ty];
    if ( round( x ) + player.rect^.w >= ( gx+1 )*16+pm ) and Assigned(cell.trigger)
    and (cell.trigger^.trigger = TRIGGER_WALL)
    then dx:=0;
  end;

  if dy < 0 then
  begin // Move up
    cell:=level.cells[tx,ty-1];
    if (round(y) <=gy*16-pm) and Assigned(cell.trigger)
    and (cell.trigger^.trigger = TRIGGER_WALL)
    then dy:=0;
  end;

  if dy > 0 then
  begin // Move down
    cell:=level.cells[tx,ty+1];
    if (round(y)+player.rect^.h >= (gy+1)*16+pm) and Assigned(cell.trigger)
    and (cell.trigger^.trigger = TRIGGER_WALL)
    then dy:=0;
  end;
  // Move player
  x:=player.x+dx;
  y:=player.y+dy;
  gx:=round(x/16);
  gy:=round(y/16);
  if gx > player.gx then inc(player.tx) else if gx < player.gx then dec(player.tx);
  if gy > player.gy then inc(player.ty) else if gy < player.gy then dec(player.ty);
  player.gx:=gx;
  player.gy:=gy;
  player.Move(dx,dy);
  tilerenderer.level.playerx:=player.tx;
  tilerenderer.level.playery:=player.ty;
  tilerenderer.camera.Update(player.tx, player.ty);
  }
  tx:=player.tx;
  ty:=player.ty;
  if dx < 0 then
  begin // left
    cell:=level.cells[tx-1,ty];
    if not CheckTile(cell) then dx:=0;
  end;

  if dx > 0 then
  begin
    cell:=level.cells[tx+1,ty];
    if not CheckTile(cell) then dx:=0;
  end;

  if dy < 0 then
  begin
    cell:=level.cells[tx,ty-1];
    if not CheckTile(cell) then dy:=0;
  end;

  if dy > 0 then
  begin
    cell:=level.cells[tx,ty+1];
    if not CheckTile(cell) then dy:=0;
  end;

  player.Move(dx,dy);
  tilerenderer.camera.Update(player.tx,player.ty);
end;

function TWizGame.CheckTile(cell: TWizCell): boolean;
begin
  result:=true;
  if Assigned(cell.trigger) and (cell.trigger^.active) then
    begin
      case cell.trigger^.trigger of
      TRIGGER_WALL:
        result:=false;
      TRIGGER_ITEM:
        begin
          if (cell.item^.active) then
          begin
            case cell.item^.item of
            ITEM_CHEST..ITEM_COIN:
              begin
              player.gold:=player.gold+cell.item^.value;
              cell.item^.active:=false;
              end;
            ITEM_KEY:
              begin
                player.keys:=player.keys+1;
                cell.item^.active:=false;
              end;
            end;
          end;
        end;
        TRIGGER_PORTAL:
          begin
            case cell.portal^.portal of
            PORTAL_DOOR1..PORTAL_DOOR2:
              begin
                if player.keys > 0 then
                begin
                  cell.portal^.locked:=false;
                  cell.portal^.active:=false;
                end;
                if player.keys = 0 then
                begin
                  result:=false;
                end;
              end;
            end;
          end;
      end;
    end;
end;

procedure TWizGame.Run;
var
  running : boolean;
  event : TSDL_Event;
begin
  running:=true;
  while running do
  begin
    while SDL_PollEvent(@event) > 0 do
    begin
      if event.type_ = SDL_QUITEV then running:=false;
      if event.type_ = SDL_KEYDOWN then begin
        case event.key.keysym.sym of
        SDLK_UP:
          MovePlayer(0,-1);
        SDLK_DOWN:
          MovePlayer(0,1);
        SDLK_LEFT:
          MovePlayer(-1,0);
        SDLK_RIGHT:
          MovePlayer(1,0);
        SDLK_ESCAPE:
          running:=false;
        end;
      end;
    end;
    window.Clear;
    tilerenderer.Render;
    //SDL_RenderCopy(window.sdlRenderer, player.texture,nil,player.rect);
    window.Update;
  end;
end;

destructor TWizGame.Destroy;
begin
  FreeAndNil(level);
  FreeAndNil(player);
  FreeAndNil(tilerenderer);
  inherited;
end;

{ TWizTileRenderer }

constructor TWizTileRenderer.Create(wnd: TWizWindow; lvl: TWizLevel);
var
  x, y : integer;
  w, h : integer;
  tw, th : integer;
begin
  sdlRenderer:=wnd.sdlRenderer;
  window:=wnd;
  level := lvl;
  void := TWizTextureManager.GetInstance.GetSDLTexture('void.png');
  gw := TWizSettings.gridWidth;
  gh := TWizSettings.gridHeight;
  tw := TWizSettings.tileWidth;
  th := TWizSettings.tileHeight;
  camera := TWizCamera.Create(level,gw,gh);
  SetLength(grid, gw, gh);
  for y:=0 to gh-1 do
  begin
    for x:=0 to gw-1 do
    begin
      grid[x,y].x := x * tw;
      grid[x,y].y := y * th;
      grid[x,y].w := tw;
      grid[x,y].h := th;
    end;
  end;
end;

destructor TWizTileRenderer.Destroy;
begin
  FreeAndNil(camera);
  inherited Destroy;
end;

procedure TWizTileRenderer.Render;
var
  x, y, i : integer;
  cell : TWizCell;
  tx,ty : integer;
  rect : TSDL_Rect;
begin
  for y:=0 to gh-1 do
  begin
    for x:=0 to gw-1 do
    begin
      tx:=x+camera.cx;
      ty:=y+camera.cy;
      SDL_SetRenderTarget(sdlRenderer,window.viewPortTexture);
      SDL_RenderCopy(sdlRenderer, level.cells[tx,ty].tile^.texture,@level.cells[tx,ty].tile^.rect, @grid[x,y]);
      if Assigned(level.cells[tx,ty].item) and (level.cells[tx,ty].item^.active) then
      SDL_RenderCopy(sdlRenderer,level.cells[tx,ty].item^.texture,@level.cells[tx,ty].item^.rect,@grid[x,y]);
      if Assigned(level.cells[tx,ty].portal) and (level.cells[tx,ty].portal^.active) then
      SDL_RenderCopy(sdlRenderer,level.cells[tx,ty].portal^.texture,@level.cells[tx,ty].portal^.rect,@grid[x,y]);
      if (x+camera.cx = level.player.tx) and (y+camera.cy = level.player.ty) then
      begin
        rect.x := grid[x,y].x+level.player.offx;
        rect.y := grid[x,y].y+level.player.offy;
        rect.w := level.player.w;
        rect.h := level.player.h;
        SDL_RenderCopy(sdlRenderer,level.player.texture,level.player.rect,@rect);
      end;
      SDL_SetRenderDrawBlendMode(sdlRenderer, SDL_BLENDMODE_BLEND);
      {$IFDEF DEBUG}
      //SDL_SetRenderDrawColor(sdlRenderer,255,255,255,126);
      //SDL_RenderDrawRect(sdlRenderer, @grid[x,y]);
      //if (level.cells[x+camera.cx,y+camera.cy].trigger<>nil) then
      //SDL_RenderCopy(sdlRenderer,level.cells[x+camera.cx,y+camera.cy].trigger^.texture,@level.cells[x+camera.cx,y+camera.cy].trigger^.rect, @grid[x,y]);
      {$ENDIF}
      SDL_SetRenderTarget(sdlRenderer,nil);
      SDL_RenderCopy(sdlRenderer,window.viewPortTexture,@camera.lens,@window.viewPort);
    end;
  end;
end;

procedure TWizTileRenderer.RenderFog;
begin
end;

procedure TWizTileRenderer.NewLevel(lvl: TWizLevel);
begin

end;

{ TWizCamera }
constructor TWizCamera.Create(lvl: TWizLevel; w,h : integer);
var
  i : integer;
  dx, dy : integer;
  dw, dh : integer;
begin
  level := lvl;
  xmin:=0;
  ymin:=0;
  offsetx:=0; offsety:=0;
  xmax:=level.width;
  ymax:=level.height;
  cw:=w;
  ch:=h;
  px:=level.playerx;
  py:=level.playery;
  cx:=px-round(cw/2);
  if cx < 0 then
  begin
    cx := 0;
    edgeLeft:=true;
    edgeRight:=false;
  end;
  cy:=py-round(ch/2);
  if cy < 0 then
  begin
    cy := 0;
    edgeTop:=true;
    edgeBottom:=false;
  end;
  if cy + cw > ymax then
  begin
    cy:=ymax-ch;
    edgeTop:=false;
    edgeBottom:=true;
  end;
  if cw + cx > xmax then
  begin
    cx:=xmax-cw;
    edgeRight:=true;
    edgeLeft:=false;
  end;
  lens.x:=16; lens.y:=16;
  lens.w:=cw*TWizSettings.tileWidth-32;
  lens.h:=ch*TWizSettings.tileHeight-32;
  dx := round(cw/2 - 2 * TWizSettings.tileWidth);
  dy := round(ch/2 - 2 *TWizSettings.tileHeight);
  dw := 2 * TWizSettings.tileWidth;
  dh := 2 * TWizSettings.tileHeight;
  focus.x:=dx;
  focus.y:=dy;
  focus.w:=dw;
  focus.h:=dy;
  dx:=px-cx;
  dy:=py-cy;
  prect.w:=TWizSettings.playerWidth;
  prect.h:=TWizSettings.playerHeight;
  prect.x:=dx*TWizSettings.tileWidth + round((TWizSettings.tileWidth-TWizSettings.playerWidth)/2);
  prect.y:=dy*TWizSettings.tileHeight+round((TWizSettings.tileHeight-TWizSettings.playerHeight)/2);
end;


// dx, dy = player tilemap position
procedure TWizCamera.Update(tx, ty: integer);
var
  dx, dy : integer;
begin
   px:=tx;
  py:=ty;
  cx:=px-round(cw/2);
  if cx < 0 then
  begin
    cx := 0;
    edgeLeft:=true;
    edgeRight:=false;
  end;
  cy:=py-round(ch/2);
  if cy < 0 then
  begin
    cy := 0;
    edgeTop:=true;
    edgeBottom:=false;
  end;
  if cy + cw > ymax then
  begin
    cy:=ymax-ch;
    edgeTop:=false;
    edgeBottom:=true;
  end;
  if cw + cx > xmax then
  begin
    cx:=xmax-cw;
    edgeRight:=true;
    edgeLeft:=false;
  end;

end;

function TWizCamera.FocusCheck: boolean;
begin
  result:=true;
end;

procedure TWizCamera.ScrollTiles(dx, dy: integer);
begin

end;

{>> TWizLevel <<}
constructor TWizLevel.Create(map : TWizMap);
var
  x, y, l, t : integer;
  tile : pWizTile;
  item : pWizItem;
  portal : pWizPortal;
  trigger : pWizTrigger;
  void : PSDL_Texture;
  walls : integer;
begin
  Randomize; // Seed
  width := map.w;
  height := map.h;
  l := width* height;
  SetLength(cells, width, height);
  void:=TWizTextureManager.GetInstance.GetSDLTexture('void.png');
  count := 0; // index
  walls :=0;
  for y := 0 to map.h - 1 do
  begin
    for x := 0 to map.w - 1 do
    begin
      tile := nil;
      item := nil;
      portal := nil;
      trigger := nil;
      t := map.floormap[x,y];
      if (t > 0) and (t < 65) then
      begin
        tile := new(pWizTile);
        tile^.texture := map.tilesets[0].sdlTexture;
        Assert(tile^.texture <> nil, 'Nil texture');
        tile^.rect.x := map.tilesets[0].clip[t-1].x;
        tile^.rect.y := map.tilesets[0].clip[t-1].y;
        tile^.rect.w := map.tilesets[0].clip[t-1].w;
        tile^.rect.h := map.tilesets[0].clip[t-1].h;
        end
      else begin
        tile := new(pWizTile);
        tile^.rect.x:=0;
        tile^.rect.y:=0;
        tile^.rect.w:=16;
        tile^.rect.h:=16;
        tile^.texture:=void;
      end;
      t := map.itemmap[x,y];
      if (t >= 65) and (t < 90) then
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
      t := map.triggermap[x,y];
      if (t >= 81) and (t < 90) then
      begin
        trigger := new(pWizTrigger);
        trigger^.active:=true;
        trigger^.trigger:=t;
        {$IFDEF DEBUG}
        trigger^.texture := map.tilesets[2].sdlTexture;
        trigger^.rect.x := map.tilesets[2].clip[t-81].x;
        trigger^.rect.y := map.tilesets[2].clip[t-81].y;
        trigger^.rect.w := map.tilesets[2].clip[t-81].w;
        trigger^.rect.h := map.tilesets[2].clip[t-81].h;
        {$ENDIF}
        if t = TRIGGER_WALL then inc(walls);
        if t = TRIGGER_ENTRY then
        begin
          playerx := x;
          playery := y;
          writeln('Player position at ', x, ', ', y);
        end;
      end;
      t := map.portalmap[x,y];
      if t >= 90 then
      begin
        portal := new(pWizPortal);
        portal^.active:=true;
        portal^.portal:=t;
        portal^.texture :=  map.tilesets[3].sdlTexture;
        portal^.rect.x := map.tilesets[3].clip[t-90].x;
        portal^.rect.y := map.tilesets[3].clip[t-90].y;
        portal^.rect.w := map.tilesets[3].clip[t-90].w;
        portal^.rect.h := map.tilesets[3].clip[t-90].h;
      end;
      cells[x,y] := TWizCell.Create(x,y,tile,item,portal,trigger);
      inc(count);
    end;
  end;
  writeln('Processed ', count,' tiles');
  writeln('Counted to ', walls, ' walls');
end;
destructor TWizLevel.Destroy;
var
  x,y : integer;
begin
  for y :=0  to height-1 do
  begin
    for x:=0 to width-1 do
    begin
      if Assigned(cells[x,y]) then FreeAndNil(cells[x,y]);
    end;

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
  fogged:=true;
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


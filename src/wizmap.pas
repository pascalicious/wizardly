unit wizmap;
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
{$ASSERTIONS ON}
{
     This crap is a mess...
     FIXME!!!
}

interface

uses
  Classes, SysUtils, SDL2, DOM, XmlRead, wiztex, wizglobals;

type

  { TWizTileset }

  TWizTileset = class
    name : AnsiString;
    filename : AnsiString;
    firstgid : integer;
    tilecount : integer;
    sdlTexture : PSDL_Texture;
    texture : integer;
    textureWidth, textureHeight : integer;
    w, h : integer;
    clip : array of TSDL_Rect;
    width, height : integer; // Not pixels! TILES!!!
    tilewidth, tileheight : integer; // Pixels per tile
    offsetx, offsety : integer; // Offset for dem small ones
    procedure LoadTexture;
  end;

  { TWizMap }

  TWizMap = class
    w, h : integer; // Tiles, not pixels
    tw, th : integer; // Pixel size of tiles
    tilesets : array of TWizTileset;
    floormap : array of array of word;  // Just load the grid
    itemmap : array of array of word;   // And make 3 copies..
    portalmap : array of array of word;
    triggermap : array of array of word; // Won't matter as we're talking kb
    playerx, playery : word; // Player position in grid, not actual player pos
    next : AnsiString;
    constructor Create(xmlfile : string);
    destructor Destroy; override;
  end;

implementation

{ TWizTileset }

procedure TWizTileset.LoadTexture;
var
  t : PWizTexture;
  x, y : integer;
  count : integer;
begin
  texture:=TWizTextureManager.GetInstance.LoadTexture(filename);
  sdlTexture:=TWizTextureManager.GetInstance.GetSDLTexture(texture);
  t := TWizTextureManager.GetInstance.GetTexture(texture);
  SetLength(clip, tilecount);
  w := round(t^.width/tilewidth);
  h := round(t^.height/tileheight);
  count := 0;
  for y:=0 to h - 1 do
  begin
    for x:=0 to w - 1 do
    begin
      clip[count].x := x*tilewidth;
      clip[count].y := y*tileheight;
      clip[count].w := tilewidth;
      clip[count].h := tileheight;
      inc(count);
    end;
  end;
end;

{ TWizMap }

constructor TWizMap.Create(xmlfile: string);
var
  map : TXMLDocument;
  node : TDOMNode;
  child : TDOMNode;
  i, l : integer;
  x,y : integer;
begin
  try
    ReadXMLFile(map, xmlfile);
    node := map.DocumentElement.FirstChild;
    w:=StrToInt(AnsiString(map.DocumentElement.Attributes.GetNamedItem('width').NodeValue));
    h:=StrToInt(AnsiString(map.DocumentElement.Attributes.GetNamedItem('height').NodeValue));
    tw:=StrToInt(AnsiString(map.DocumentElement.Attributes.GetNamedItem('tilewidth').NodeValue));
    th:=StrToInt(AnsiString(map.DocumentElement.Attributes.GetNamedItem('tileheight').NodeValue));
    SetLength(floormap, w, h);
    SetLength(itemmap, w, h);
    SetLength(triggermap, w, h);
    SetLength(portalmap,w,h);
    while Assigned(node) do
    begin
      if node.NodeName = 'properties' then
      begin
        child:=node.FirstChild;
        next := AnsiString(child.Attributes[1].NodeValue);
        writeln('Next map name: ', next);
      end;
      if node.NodeName = 'tileset' then
      begin
        l := Length(tilesets);
        SetLength(tilesets, l + 1);
        tilesets[l] := TWizTileset.Create;
        with node.Attributes do
        begin
          tilesets[l].firstgid:=StrToInt(AnsiString(GetNamedItem('firstgid').NodeValue));
          tilesets[l].tilewidth := StrToInt(AnsiString(GetNamedItem('tilewidth').NodeValue));
          tilesets[l].tileheight := StrToInt(AnsiString(GetNamedItem('tileheight').NodeValue));
          tilesets[l].tilecount := StrToInt(AnsiString(GetNamedItem('tilecount').NodeValue));
          tilesets[l].name:=AnsiString(GetNamedItem('name').NodeValue);
          child := node.FirstChild;
          if node.FirstChild.NodeName = 'tileoffset' then
          begin
            tilesets[l].offsetx:=StrToInt(AnsiString(child.Attributes.Item[0].NodeValue));
            tilesets[l].offsety:=StrToInt(AnsiString(child.Attributes.Item[1].NodeValue));
            child := child.NextSibling;
            end
          else
          begin
            tilesets[l].offsetx:=0;
            tilesets[l].offsety:=0;
          end;
          tilesets[l].filename := AnsiString(child.Attributes.GetNamedItem('source').NodeValue);
          tilesets[l].LoadTexture;
        end;
      end;
      if node.NodeName = 'layer' then
      begin
        child := node.FirstChild.FirstChild;
        if node.Attributes.GetNamedItem('name').NodeValue = 'Floor' then
        begin
          writeln('building floor layer');
          for y := 0 to h - 1 do
          begin
            for x := 0 to w - 1 do
            begin
              floormap[x,y] := StrToInt(AnsiString(child.Attributes.GetNamedItem('gid').NodeValue));
              child := child.NextSibling;
            end;
          end;
        end;

        if node.Attributes.GetNamedItem('name').NodeValue = 'Portals' then
        begin
          writeln('building portals layer');
          for y := 0 to h - 1 do
          begin
            for x := 0 to w - 1 do
            begin
              portalmap[x,y] := StrToInt(AnsiString(child.Attributes.GetNamedItem('gid').NodeValue));
              child := child.NextSibling;
            end;
          end;
        end;

        if node.Attributes.GetNamedItem('name').NodeValue = 'Item' then
        begin
          writeln('building item layer');
          for y := 0 to h - 1 do
          begin
            for x := 0 to w - 1 do
            begin
              itemmap[x,y] := StrToInt(AnsiString(child.Attributes.GetNamedItem('gid').NodeValue));
              child := child.NextSibling;
            end;
          end;
        end;

        if node.Attributes.GetNamedItem('name').NodeValue = 'Trigger' then
        begin
          writeln('processing triggers');
          for y := 0 to h - 1 do
          begin
            for x := 0 to w - 1 do
            begin
              triggermap[x,y] := StrToInt(AnsiString(child.Attributes.GetNamedItem('gid').NodeValue));
              child := child.NextSibling;
            end;
          end;
        end;
      end;
      node := node.NextSibling;
    end;
  finally
    map.Free;
  end;
end;

destructor TWizMap.Destroy;
var
  i,x,y : integer;
begin
  if Length(tilesets) > 0 then
  begin
    for i := Low(tilesets) to High(tilesets) do
    begin
      FreeAndNil(tilesets[i]);
    end;
  end;

  SetLength(floormap,0,0);
  SetLength(itemmap,0,0);
  SetLength(triggermap,0,0);
  SetLength(portalmap,0,0);
end;

end.

{ vim: set ts=2 sw=2 tw=0  }

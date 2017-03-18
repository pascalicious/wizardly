unit wiztex;
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
interface

uses
    Classes, SysUtils, wizsys,SDL2, SDL2_image;
const
  PROJ_PATH : AnsiString = 'assets';
  PATH_DELIM : AnsiString = '/';
type
    TWizTexture = record
        sdlTexture : PSDL_Texture;
        filename : string;
        width : integer;
        height : integer;
    end;
    PWizTexture = ^TWizTexture;

    { TWizTextureManager }

    TWizTextureManager = class
        class var instance : TWizTextureManager;
        textures : array of PWizTexture;
        wizwin : TWizWindow;
        constructor Create(win : TWizWindow);
        destructor Destroy; override;
        function FindTexture(filename : AnsiString) : integer;
        function GetSDLTexture(id : integer) : PSDL_Texture;
        function GetTexture(id : integer) : PWizTexture;
        function LoadTexture(filename : AnsiString) : integer;
        class function GetInstance:TWizTextureManager;
    end;
implementation
{>> TWizTextureManager <<}
constructor TWizTextureManager.Create(win : TWizWindow);
var
    i : integer;
begin
    i := IMG_Init(IMG_INIT_PNG);
    Assert(i <> 0, SDL_GetError);
    wizwin := win;
    instance := self;
end;

class function TWizTextureManager.GetInstance: TWizTextureManager;
begin
    Assert(instance <> nil, 'Maybe instanicate the class before you try to access it?');
    result := instance;
end;

destructor TWizTextureManager.Destroy;
var
    i : integer;
    t : PWizTexture;
begin
    for i := Low(textures) to High(textures) do
    begin
        t := textures[i];
        if Assigned(t) then
        begin
            if Assigned(t^.sdlTexture) then SDL_DestroyTexture(t^.sdlTexture);
            t^.sdlTexture := nil;
            t^.filename := '';
            dispose(t);
            textures[i] := nil;
        end;
    end;
    SetLength(textures,0);
end;

function TWizTextureManager.FindTexture(filename: AnsiString): integer;
var
    i : integer;
begin
    for i := Low(textures) to High(textures) do
    begin
        if textures[i]^.filename = filename then exit(i);
    end;
    result := -1;
end;

function TWizTextureManager.GetSDLTexture(id : integer) : PSDL_Texture;
begin
    Assert(Length(textures) <> 0, 'Load them textures first, asshat!');
    Assert(id < Length(textures), 'Yeah. Sure. Thought of loading it first?');
    result := textures[id]^.sdlTexture

end;

function TWizTextureManager.GetTexture(id : integer) : PWizTexture;
begin
    Assert(Length(textures) <> 0, 'Accesing an emoty array is kinda dumb!');
    Assert(id < Length(textures), 'Out of bounds you idiot!');
    result := textures[id];
end;

function TWizTextureManager.LoadTexture(filename : AnsiString) : integer;
var
    t : PSDL_Texture;
    i : integer;
begin
    i := FindTexture(filename);
    if i <> -1 then exit(i);
    t := IMG_LoadTexture(wizwin.sdlRenderer, pAnsiChar(PROJ_PATH + PATH_DELIM + filename));
    Assert(t <> nil, SDL_GetError);
    // Found the file, made a texture. Now insert in the array.
    writeln('Loading texture ', filename);
    i := Length(textures);
    SetLength(textures, i + 1);
    i := High(textures);
    textures[i] := new(PWizTexture);
    textures[i]^.filename := filename;
    textures[i]^.sdlTexture := t;
    SDL_QueryTexture(t, nil, nil, @textures[i]^.width, @textures[i]^.height);
    result := i;
end;

{<< TWizTextureManager >>}
end.

{ vim: set ts=2 sw=2 tw=0  }

unit Classes.shearche.item;

interface

uses Classes.shearche.snippet, Classes.shearche.id;

type
  Tshearche_item = class
  private
    Fkind: string;
    Fetag: string;
    Fid: Tshearche_id; // id видео
    Fsnippet: Tshearche_snippet; // описание видео
  public
    property kind: string read Fkind write Fkind;
    property etag: string read Fetag write Fetag;
    property id: Tshearche_id read Fid write Fid;
    property snippet: Tshearche_snippet read Fsnippet write Fsnippet;
  end;

implementation

end.
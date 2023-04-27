unit Classes.video.item;

interface

uses Classes.video.snippet, Classes.shearche.id;

type
  Tvideo_item = class
  private
    Fkind: string;
    Fetag: string;
    Fid: Tshearche_id; // id видео
    Fsnippet: Tvideo_snippet; // описание видео
  public
    property kind: string read Fkind write Fkind;
    property etag: string read Fetag write Fetag;
    property id: Tshearche_id read Fid write Fid;
    property snippet: Tvideo_snippet read Fsnippet write Fsnippet;
  end;

implementation

end.
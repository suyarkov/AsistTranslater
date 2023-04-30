unit Classes.channel;

interface

uses Classes.shearche.pageInfo, Classes.channel.item;

type
  Tchannel = class
  type TChItems = array of Tchannel_item;
  private
    Fkind: string;
    Fetag: string;
    FnextPageToken: string;
    FpageInfo : Tshearche_pageInfo;
    Fitems: TChItems;

  public
    property kind: string read Fkind write Fkind;
    property etag: string read Fetag write Fetag;
    property nextPageToken: string read FnextPageToken write FnextPageToken;
    property pageInfo: Tshearche_pageInfo read FpageInfo write FpageInfo;
    property items: TChItems read Fitems write Fitems;
  end;

implementation

end.
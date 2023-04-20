unit Classes.shearche;

interface

uses Classes.shearche.pageInfo, Classes.shearche.item;

type
  Tshearche = class
  type Titems = array of Tshearche_item;
  private
    Fkind: string;
    Fetag: string;
    FregionCode: string;
    FpageInfo : Tshearche_pageInfo;
    Fitems: Titems;

  public
    property kind: string read Fkind write Fkind;
    property etag: string read Fetag write Fetag;
    property regionCode: string read FregionCode write FregionCode;
    property pageInfo: Tshearche_pageInfo read FpageInfo write FpageInfo;
    property items: Titems read Fitems write Fitems;
  end;

implementation

end.
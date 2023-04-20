unit Classes.channel.snippet;

interface

uses Classes.shearche.thumbnails;

type
  Tchannel_snippet = class
  private
    Ftitle: string;
    Fdescription: string; //5000 символов
    FcustomUrl: string;
    FpublishedAt: string; // дата формата "2023-03-21T11:50:33Z"
    Fthumbnails: Tshearche_thumbnails; // описание картинок
    FdefaultLanguage: string;
    Fcountry: string;
  public
    property title: string read Ftitle write Ftitle;
    property customUrl: string read FcustomUrl write FcustomUrl;
    property description: string read Fdescription write Fdescription;
    property publishedAt: string read FpublishedAt write FpublishedAt;
    property thumbnails: Tshearche_thumbnails read Fthumbnails write Fthumbnails;
    property defaultLanguage: string read FdefaultLanguage write FdefaultLanguage;
    property country: string read Fcountry write Fcountry;
  end;

implementation

end.
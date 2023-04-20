unit Classes.shearche.snippet;

interface

uses Classes.shearche.thumbnails ;

type
  Tshearche_snippet = class
  private
    FpublishedAt: string; // дата формата "2023-03-21T11:50:33Z"
    FchannelId: string;
    Ftitle: string;
    Fdescription: string; //5000 символов
    Fthumbnails: Tshearche_thumbnails; // описание картинок
    FchannelTitle: string;
    FliveBroadcastContent: string;
    FpublishTime: string; // дата формата "2023-03-21T11:50:33Z"
  public
    property publishedAt: string read FpublishedAt write FpublishedAt;
    property channelId: string read FchannelId write FchannelId;
    property title: string read Ftitle write Ftitle;
    property description: string read Fdescription write Fdescription;
    property thumbnails: Tshearche_thumbnails read Fthumbnails write Fthumbnails;
    property channelTitle: string read FchannelTitle write FchannelTitle;
    property liveBroadcastContent: string read FliveBroadcastContent write FliveBroadcastContent;
    property publishTime: string read FpublishTime write FpublishTime;
  end;

implementation

end.
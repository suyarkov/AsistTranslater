unit Classes.shearche.id;

interface

type
  Tshearche_id = class

  private
    Fkind: string;
    FvideoId: string;
    FchannelId: string;

  public
    property kind: string read Fkind write Fkind;
    property videoId: string read FvideoId write FvideoId;
    property channelId: string read FchannelId write FchannelId;
  end;

implementation

end.
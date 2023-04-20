unit Classes.channel.statistics;

interface

type
  Tchannel_statistics = class

  private
    FviewCount: integer;
    FsubscriberCount: integer;
    FhiddenSubscriberCount: boolean;
    FvideoCount: integer;

  public
    property viewCount: integer read FviewCount write FviewCount;
    property subscriberCount: integer read FsubscriberCount write FsubscriberCount;
    property hiddenSubscriberCount: boolean read FhiddenSubscriberCount write FhiddenSubscriberCount;
    property videoCount: integer read FvideoCount write FvideoCount;
  end;

implementation

end.
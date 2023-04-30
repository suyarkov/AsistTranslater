unit Classes.channel.items;

interface

uses Classes.channel.item;

type
  Tchannel_items = class

  private type
    Titems = array of Tchannel_item;
  var
    Fitems: Titems;

  public
    property items: Titems read Fitems write Fitems;

  end;

implementation

end.

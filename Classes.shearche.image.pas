unit Classes.shearche.image;

interface

type
  Tshearche_image = class
  private
    Furl: string;
    Fwidth: integer;
    Fheight: integer;

  public
    property url: string read Furl write Furl;
    property width: integer read Fwidth write Fwidth;
    property height: integer read Fheight write Fheight;
  end;

implementation

end.
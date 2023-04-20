unit Classes.shearche.thumbnails;

interface

uses Classes.shearche.image ;

type
  Tshearche_thumbnails = class
  private
    Fdefault: Tshearche_image;
    Fmedium: Tshearche_image;
    Fhigh: Tshearche_image;
  public
    property default: Tshearche_image read Fdefault write Fdefault;
    property medium: Tshearche_image read Fmedium write Fmedium;
    property high: Tshearche_image read Fhigh write Fhigh;
  end;

implementation

end.
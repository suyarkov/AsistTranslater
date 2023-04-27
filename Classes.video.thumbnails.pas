unit Classes.video.thumbnails;

interface

uses Classes.shearche.image ;

type
  Tvideo_thumbnails = class
  private
    Fdefault: Tshearche_image;
    Fmedium: Tshearche_image;
    Fhigh: Tshearche_image;
    Fstandard: Tshearche_image;
    Fmaxres: Tshearche_image;
  public
    property default: Tshearche_image read Fdefault write Fdefault;
    property medium: Tshearche_image read Fmedium write Fmedium;
    property high: Tshearche_image read Fhigh write Fhigh;
    property standard: Tshearche_image read Fstandard write Fstandard;
    property maxres: Tshearche_image read Fmaxres write Fmaxres;
  end;

implementation

end.
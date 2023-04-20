unit Classes.shearche.items;

interface

uses Classes.shearche.item;

type
  Tshearche_items = class
    {
      //объ€вл€ю
      A: array of TMyClass

      //увеличиваю длину
      SetLength(A,Length(A)+1);

      //создаю объект
      A[i]:= TMyClass.Create;
    }

  private type
    Titems = array of Tshearche_item;
  var
    Fitems: Titems;

  public
    property items: Titems read Fitems write Fitems;

  end;

implementation

end.

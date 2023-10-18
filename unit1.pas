unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, EvenkiProc, Unit2, Unit3;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    FontDialog1: TFontDialog;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  sInGlob,sOutGlob:String;
  tsDet,tsStIn,tsStOut:TStrings;

implementation

{$R *.lfm}
uses StrUtilsEv;
{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  sInGlob:=Edit1.Text;
  MainWork(sInGlob,sOutGlob,tsDet,tsStIn,tsStOut);
  Memo1.Lines.Clear;
  Memo1.Lines.Add(sOutGlob);
  Button3.Enabled:=True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  If FontDialog1.Execute then begin
    Edit1.Font:=FontDialog1.Font;
    if Edit1.Font.Size>24 then Edit1.Font.Size:=24;
    Memo1.Font:=FontDialog1.Font;
    //ShowMessage('Font '+FontDialog1.Font.Name+' Height '+i2str(FontDialog1.Font.Height))
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Unit2.Form2.Memo1.Lines.Clear;
  Unit2.Form2.Memo1.Lines.AddStrings(tsDet);
  Unit2.Form2.Memo2.Lines.Clear;
  Unit2.Form2.Memo2.Lines.AddStrings(tsStIn);
  Unit2.Form2.Memo3.Lines.Clear;
  Unit2.Form2.Memo3.Lines.AddStrings(tsStOut);
  Unit2.Form2.Show;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Edit1.Width:=Form1.Width-4*2;
  Memo1.Width:=Edit1.Width;
  Button4.Top:=Form1.Height-4-Button4.Height-24;
  Button1.Top:=Button4.Top-4*2-Button1.Height;
  Button2.Top:=Button1.Top;
  Button3.Top:=Button1.Top;
  Memo1.Height:=Button1.Top-4*2-Memo1.Top;
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  Unit3.Form3.Show;
end;


begin
  tsDet:=TStringList.Create;
  tsStIn:=TStringList.Create;
  tsStOut:=TStringList.Create;
  sInGlob:='';
  sOutGlob:='';
end.


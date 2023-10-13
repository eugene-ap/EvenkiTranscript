unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, EvenkiProc, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Edit1: TEdit;
    FontDialog1: TFontDialog;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  sInGlob,sOutGlob:String;
  tsDet,tsStIn,tsStOut:TStrings;

implementation

{$R *.lfm}

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
    Memo1.Font:=FontDialog1.Font;
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

begin
  tsDet:=TStringList.Create;
  tsStIn:=TStringList.Create;
  tsStOut:=TStringList.Create;
  sInGlob:='';
  sOutGlob:='';
end.


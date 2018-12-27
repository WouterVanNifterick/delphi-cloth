program ClothDemo;

uses
  FastMM4,
  Vcl.Forms,
  Cloth.Main.Form in 'Cloth.Main.Form.pas' {frmMain},
  ClothDemo.Cloth in 'ClothDemo.Cloth.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

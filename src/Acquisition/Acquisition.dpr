program Acquisition;

uses
  Vcl.Forms,
  pasMain in 'pasMain.pas' {Form1},
  TOPAPI in '..\Public_pas\TOPAPI.pas',
  Alimama_Const in '..\Public_pas\Alimama_Const.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

program Countdown;

uses
  Forms,
  CountdownForm in 'CountdownForm.pas' {FormCountdown};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormCountdown, FormCountdown);
  Application.Run;
end.

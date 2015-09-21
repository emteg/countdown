unit CountdownForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, DateUtils, Registry, ImgList;

type
  TFormCountdown = class(TForm)
    DtpAnfangDatum: TDateTimePicker;
    DtpAnfangZeit: TDateTimePicker;
    DtpEndeZeit: TDateTimePicker;
    DtpEndeDatum: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox: TGroupBox;
    Timer: TTimer;
    ProgressBar: TProgressBar;
    LblSekunden: TLabel;
    Button: TButton;
    LblProzent: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LblMonate: TLabel;
    LblTage: TLabel;
    LblStunden: TLabel;
    LblMinuten: TLabel;
    LblSek: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    TrayIcon: TTrayIcon;
    procedure DtpAnfangDatumChange(Sender: TObject);
    procedure DtpEndeDatumChange(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
  private
    fStart, fEnde: TDateTime;
  public
    { Public-Deklarationen }
  end;

var
  FormCountdown: TFormCountdown;

implementation

{$R *.dfm}

procedure TFormCountdown.ButtonClick(Sender: TObject);
var
  reg: TRegistry;
begin
  if Button.Caption = 'Speichern' then
  begin
    fStart := DtpAnfangZeit.DateTime;
    fEnde := DtpEndeZeit.DateTime;

    if fEnde <= fStart then
    begin
      ShowMessage('Die Endzeit muss kleiner als die Anfangszeit sein.');
      exit;
    end;

    if fEnde <= Now then
    begin
      ShowMessage('Die Endzeit muss in der Zukunft liegen.');
      exit;
    end;

    ProgressBar.Min := 0;
    ProgressBar.Max := SecondsBetween(fEnde, fStart);
    ProgressBar.Position := 0;

    Button.Caption := 'Ändern';
    Timer.Enabled := true;
    GroupBox.Enabled := false;
    ClientHeight := 163;

    try
      reg := TRegistry.Create;
      reg.RootKey := HKEY_CURRENT_USER;
      reg.OpenKey('Software\emteg\Countdown\1.0', true);
      reg.WriteDateTime('start', fStart);
      reg.WriteDateTime('ende', fEnde);
    finally
      reg.Free;
    end;

    TimerTimer(nil);
  end
  else
  begin
    Timer.Enabled := false;
    GroupBox.Enabled := true;
    ClientHeight := 333;
    Button.Caption := 'Speichern';
  end;
end;

procedure TFormCountdown.DtpAnfangDatumChange(Sender: TObject);
begin
  DtpAnfangZeit.Date := DtpAnfangDatum.Date;
end;

procedure TFormCountdown.DtpEndeDatumChange(Sender: TObject);
begin
  DtpEndeZeit.Date := DtpEndeDatum.Date;
end;

procedure TFormCountdown.FormCreate(Sender: TObject);
var
  reg: TRegistry;
  loaded: boolean;
begin
  fStart := Now;
  fEnde := Now;
  loaded := false;

  try
    reg := TRegistry.Create;
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\emteg\Countdown\1.0', false) then
    begin
      if reg.ValueExists('start') then
        fStart := reg.ReadDateTime('start');

      if reg.ValueExists('ende') then
        fEnde := reg.ReadDateTime('ende');

      loaded := true;
    end;
  finally
    reg.Free;
  end;

  DtpAnfangDatum.Date := fStart;
  DtpAnfangZeit.DateTime := fStart;

  DtpEndeDatum.Date := fEnde;
  DtpEndeZeit.DateTime := fEnde;

  if loaded then
    ButtonClick(nil);

end;

procedure TFormCountdown.TimerTimer(Sender: TObject);
var
  secondsPassed, secondsLeft, secondsLeftOver, minutesLeft, hoursLeft,
  daysLeft, monthsLeft: Integer;
begin

  if fStart <= Now then
  begin
    secondsPassed := SecondsBetween(Now, fStart);
    secondsLeft := SecondsBetween(Now, fEnde);

    if secondsLeft <> 1 then
      LblSekunden.Caption := IntToStr(secondsLeft) + ' Sekunden'
    else
      LblSekunden.Caption := '1 Sekunde';
  end
  else
  begin
    secondsPassed := 0;
    secondsLeft := SecondsBetween(Now, fStart);

    if secondsLeft <> 1 then
      LblSekunden.Caption := IntToStr(secondsLeft) +
        ' Sekunden (bis Start des Countdowns)'
    else
      LblSekunden.Caption := '1 Sekunde (bis Start des Countdowns)';
  end;

  minutesLeft := Trunc(secondsLeft / 60);
  secondsLeftOver := secondsLeft - minutesLeft * 60;
  hoursLeft := Trunc(minutesLeft / 60);
  minutesLeft := minutesLeft - hoursLeft * 60;
  daysLeft := Trunc(hoursLeft / 24);
  hoursLeft := hoursLeft - daysLeft * 24;
  monthsLeft := Trunc(daysLeft / 30.43688);            // Durchschn. Länge eines
  daysLeft := daysLeft - Round(monthsLeft * 30.43688); // Monats in Tagen

  ProgressBar.Position := secondsPassed;
  LblMonate.Caption := IntToStr(monthsLeft);
  LblTage.Caption := IntToStr(daysLeft);

  if hoursLeft < 10 then
    LblStunden.Caption := '0' + IntToStr(hoursLeft)
  else
    LblStunden.Caption := IntToStr(hoursLeft);

  if minutesLeft < 10 then
    LblMinuten.Caption := '0' + IntToStr(minutesLeft)
  else
    LblMinuten.Caption := IntToStr(minutesLeft);

  if secondsLeftOver < 10 then
    LblSek.Caption := '0' + IntToStr(secondsLeftOver)
  else
    LblSek.Caption := IntToStr(secondsLeftOver);


  LblProzent.Caption :=
    IntToStr(Round(ProgressBar.Position / ProgressBar.Max * 100)) + ' %';

  TrayIcon.Hint := Format('%d:%d %.2d:%.2d:%.2d', [monthsLeft, daysLeft, hoursLeft, minutesLeft, secondsLeftOver]);

  if fEnde <= Now then
    Timer.Enabled := false;
end;

procedure TFormCountdown.TrayIconClick(Sender: TObject);
begin
  if not Showing then
   Show
  else
    Hide;
end;

end.

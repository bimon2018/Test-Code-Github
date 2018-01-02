unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.onguard,Vcl.ogutil, Vcl.StdCtrls,
  Vcl.Buttons;

type
  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    EdSerial: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edmachine: TEdit;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function IsReleaseCodeValid (ReleaseCodeString: string; const SerialNumber : longint) : boolean;
  private
    { Private declarations }
    pvKunci : TKey;
    MachineModifier : longint;
    pvExp_date : TDateTime;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit2;

const AppKey : TKey = ($18,$91,$06,$CA,$A9,$3C,$9E,$C8,$1C,$E2,$BE,$F7,$C6,$D6,$00,$39);

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
var i : byte;
    digit : string;
    lStatus : TCodeStatus;
begin
  form2 := TForm2.Create(self);
  Form2.Show;

  {
  if Length(EdSerial.Text)=32 then
  begin
    for i := 0 to 15 do
    begin
      pvKunci[i] := 0;
    end;

    for i := 0 to 15 do
    begin
      digit := '$'+Copy(EdSerial.Text,i*2+1,2);
      pvKunci[i] := StrToInt(digit);
      //ShowMessage(digit);
      //ShowMessage(IntToStr(pvkunci[i]));
    end;

    if datecode.IsCodeValid then
    begin
      Form2 := TForm2.Create(self);
      Form2.ShowModal;
    end else ShowMessage('Kode salah');
  end else ShowMessage('Serial harus 32 digit');  }
end;

function TForm1.IsReleaseCodeValid (ReleaseCodeString: string; const SerialNumber : longint) : boolean;
var
  CalculatedReleaseCode : TCode;
  Machine_Modifier : longint;
  DateCode : TCode;
  sDateCode : string;
  sReleaseCode : string;
begin
  pvKunci := AppKey;
  try
    Machine_Modifier := StrToInt64(edMachine.Text);
    ApplyModifierToKeyPrim(Machine_Modifier, pvKunci, sizeof(pvKunci));
  except
    MessageDlg('Invalid Machine Modifier.  Please check your entry and try again.', mtError, [mbOK], 0);
    exit;
  end;

  pvExp_date := 0;

  // Remove spaces from the Release code
  while pos('-', ReleaseCodeString) > 0 do
    System.Delete(ReleaseCodeString, pos('-', ReleaseCodeString), 1);

  sReleaseCode := Copy(ReleaseCodeString,1,16);
  sDateCode := Copy(ReleaseCodeString,17,16);

  HexToBuffer(sDateCode,DateCode, sizeof(DateCode));
  ShowMessage('Code Starts on : '+ FormatDateTime('dd-mm-yyyy',GetDateCodeStart(pvKunci,DateCode)));
  ShowMessage('Code Ends on : '+ FormatDateTime('dd-mm-yyyy',GetDateCodeEnd(pvKunci,DateCode)));

  // Calculate the release code based on the serial number and the calculated machine modifier
  InitSerialNumberCode(pvKunci, SerialNumber, pvExp_date, CalculatedReleaseCode);

  // Compare the two release codes
  if AnsiUpperCase(sReleaseCode) =
  AnsiUpperCase(BufferToHex(CalculatedReleaseCode, sizeof(CalculatedReleaseCode))) then
  begin
    result := True;
  end else Result := false;

  {convert retrieved string to a code}
  //HexToBuffer(ReleaseCodeString, CalculatedReleaseCode, SizeOf(CalculatedReleaseCode));

  //ShowMessage(FormatDateTime('dd-mm-yyyy',GetDateCodeValue(pvKunci, CalculatedReleaseCode)));
  //Result := true;

end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var
  ReleaseCodeString: string;
  var SerialNumber : longint;
begin
  SerialNumber := 0;
  ReleaseCodeString := EdSerial.Text;
  if IsReleaseCodeValid (ReleaseCodeString, SerialNumber) then
    Label1.Caption := 'VALID'
  else
    Label1.Caption := 'Unregistered Demo!';
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  MachineModifier := ABS(CreateMachineID([midUser, midSystem, {midNetwork,} midDrives]));
  edMachine.Text := format('%d',[MachineModifier]);
end;

end.

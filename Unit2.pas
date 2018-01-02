unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ogutil,
  Vcl.ComCtrls, Vcl.onguard;

type
  TForm2 = class(TForm)
    Label2: TLabel;
    edmachine: TEdit;
    EdSerial: TEdit;
    Label1: TLabel;
    dttglexpired: TDateTimePicker;
    cekExpired: TCheckBox;
    Button1: TButton;
    makeys: TOgMakeKeys;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    applicationKey : TKey;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

const AppKey : TKey = ($18,$91,$06,$CA,$A9,$3C,$9E,$C8,$1C,$E2,$BE,$F7,$C6,$D6,$00,$39);

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
var
    Key : TKey;
    Modifier : longint;
    SerialNum : longint;
    //TglAwal : Word;
    Expires : Word;
    SerialCode : TCode;
    DateCode : TCode;
    sSerialCode : string;
    sDateCode : string;

begin
  SerialNum := 0;
  Expires := 0;
  {
  if makeys.Execute then begin
    makeys.GetKey(ApplicationKey);
    ShowMessage( BufferToHex(ApplicationKey, sizeof(ApplicationKey)));
  end;}

  Key := AppKey;
  //Key := applicationKey;

  try
    Modifier := StrToInt64(edMachine.Text);
    ApplyModifierToKeyPrim(Modifier, Key, sizeof(Key));
  except
    MessageDlg('Invalid Machine Modifier.  Please check your entry and try again.', mtError, [mbOK], 0);
    exit;
  end;
  //7593 adalah 15 oktober 2016 , batas akhir expired 2100-Des-12
  if (Trunc(Date)<7593)or(Trunc(Date)> EncodeDate(2100,12,31)) then
  begin
    ShowMessage('Wrong date value');
    close;
  end;


  if cekExpired.Checked then
  begin
    //Expires := Trunc(dttglexpired.Date);
    InitDateCode(Key,Date,dttglexpired.Date,DateCode);
  end else
  begin
    //Expires := 0;
    InitDateCode(Key,Date,EncodeDate(2100,12,31),DateCode);
  end;

  // Create the release code for the data givien
  InitSerialNumberCode(Key, SerialNum, Expires, SerialCode);

  ShowMessage('Code Starts on : '+ FormatDateTime('dd-mm-yyyy',GetDateCodeStart(Key,DateCode)));
  ShowMessage('Code Ends on : '+ FormatDateTime('dd-mm-yyyy',GetDateCodeEnd(Key,DateCode)));
  {
  ShowMessage('value : '+ FormatDateTime('dd-mm-yyyy',ReleaseCode.Value));
  ShowMessage('days : '+ FormatDateTime('dd-mm-yyyy',ReleaseCode.Days));
  ShowMessage('expired : '+FormatDateTime('dd-mm-yyyy',ReleaseCode.Expiration));
  ShowMessage('end date : '+FormatDateTime('dd-mm-yyyy',ReleaseCode.EndDate));
  ShowMessage('Serial Number : '+ IntToStr(ReleaseCode.SerialNumber)); }

  sDateCode := BufferToHex(DateCode, sizeof(DateCode));
  sSerialCode := BufferToHex(SerialCode, sizeof(SerialCode));

  // Insert spaces in the release code string for easier reading
  System.Insert('-', sDateCode, 13);
  System.Insert('-', sDateCode, 09);
  System.Insert('-', sDateCode, 05);

  System.Insert('-', sSerialCode, 13);
  System.Insert('-', sSerialCode, 09);
  System.Insert('-', sSerialCode, 05);

  EdSerial.Text := sSerialCode //+'-'+sDateCode;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  dttglexpired.Date := date;
end;

end.

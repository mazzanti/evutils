unit MainPoppy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OverbyteIcsWndControl, OverbyteIcsPop3Prot
  , inifiles;

type
  TFPop = class(TForm)
    Pop3Client: TPop3Cli;
    popusr: TEdit;
    poppass: TEdit;
    btnconnect: TButton;
    pophost: TEdit;
    DisplayMemo: TMemo;
    popport: TEdit;
    InfoLabel: TLabel;
    btnuser: TButton;
    btnpass: TButton;
    btnnext: TButton;
    MsgNumEdit: TEdit;
    SubjectEdit: TEdit;
    FromEdit: TEdit;
    ToEdit: TEdit;
    retr: TButton;
    lstall: TButton;
    list: TButton;
    open: TButton;
    getall: TButton;
    procedure openClick(Sender: TObject);
    procedure btnnextClick(Sender: TObject);
    procedure listClick(Sender: TObject);
    procedure lstallClick(Sender: TObject);
    procedure retrClick(Sender: TObject);
    procedure btnpassClick(Sender: TObject);
    procedure btnuserClick(Sender: TObject);
    procedure btnconnectClick(Sender: TObject);

    procedure Pop3ClientMessageBegin(Sender: TObject);
    procedure Pop3ClientMessageEnd(Sender: TObject);
    procedure Pop3ClientMessageLine(Sender: TObject);
    procedure Pop3ClientListBegin(Sender: TObject);
    procedure Pop3ClientListEnd(Sender: TObject);
    procedure Pop3ClientListLine(Sender: TObject);
    procedure Pop3ClientDisplay(Sender: TObject; Msg: String);
    procedure Pop3ClientUidlBegin(Sender: TObject);
    procedure Pop3ClientUidlEnd(Sender: TObject);
    procedure Pop3ClientUidlLine(Sender: TObject);

    procedure NextButtonClick(Sender: TObject);
    procedure GetAllButtonClick(Sender: TObject);
    procedure Pop3ClientHeaderEnd(Sender: TObject);
  private

    FIniFileName  : String;
    FInitialized  : Boolean;
    FFile         : TextFile;
    FFileName     : String;
    FFileOpened   : Boolean;
    FGetAllState  : Integer;
    FMsgPath      : String;
    procedure MessageBegin(Sender: TObject);
    procedure MessageLine(Sender: TObject);
    procedure GetAllMessageLine(Sender: TObject);
    procedure GetAllRequestDone(Sender: TObject;
                                RqType: TPop3Request; ErrCode: Word);
    procedure NextMessageRequestDone(Sender: TObject;
                                     RqType: TPop3Request; ErrCode: Word);
    procedure Pop3ClientRequestDone(Sender: TObject; RqType: TPop3Request;
      ErrCode: Word);                                     
procedure Exec(
    MethodPtr  : TPop3NextProc;
    MethodName : String);
  end;

var
  FPop: TFPop;

implementation

{$R *.dfm}

uses OverbyteIcsMailRcv2;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This event handler is called when the TPop3Client object wants to display }
{ some information such as connection progress or errors.                   }
procedure TFPop.Pop3ClientDisplay(
    Sender : TObject;
    Msg    : String);
begin
    DisplayMemo.Lines.Add(Msg);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ All the TPop3Client method are of the same type. To simplify this demo    }
{ application, Exec transfert the parameters form the various EditBoxes     }
{ to the Pop3Client instance and then call the appropriate method, showing  }
{ the result in the InfoLabel.Caption.                                      }
procedure TFPop.btnconnectClick(Sender: TObject);
begin
    Exec(Pop3Client.Connect, 'Connect');
end;

procedure TFPop.btnnextClick(Sender: TObject);
begin
    MessageForm.DisplayMemo.Clear;
    MessageForm.Caption       := 'Message';
    Pop3Client.OnMessageBegin := MessageBegin;
    Pop3Client.OnMessageEnd   := nil;
    Pop3Client.OnMessageLine  := MessageLine;
    Pop3Client.OnRequestDone  := NextMessageRequestDone;
    Pop3Client.MsgNum         := StrToInt(MsgNumEdit.Text);
    Pop3Client.Retr;
end;

procedure TFPop.btnpassClick(Sender: TObject);
begin
    Exec(Pop3Client.Pass, 'Pass');
end;

procedure TFPop.btnuserClick(Sender: TObject);
begin
    Exec(Pop3Client.User, 'User');
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This event handler is called when TPop3Client is about to receive a       }
{ message. The MsgNum property gives the message number.                    }
{ This event handler could be used to open the file used to store the msg.  }
{ The file handle could be stored in the TPop3Client.Tag property to be     }
{ easily retrieved by the OnMessageLine and OnMessageEnd event handlers.    }
procedure TFPop.Pop3ClientMessageBegin(Sender: TObject);
begin
    DisplayMemo.Lines.Add('*** Message ' +
                          IntToStr((Sender as TPop3Cli).MsgNum) +
                          ' begin ***');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This event handler is called when TPop3Client has detected the end of a   }
{ message, even if there is an error or exception, this event gets called.  }
{ This event handler could be used to close the file used to store the msg. }
procedure TFPop.Pop3ClientMessageEnd(Sender: TObject);
begin
    DisplayMemo.Lines.Add('*** Message ' +
                          IntToStr((Sender as TPop3Cli).MsgNum) +
                          ' end ***');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This event handler is called for each message line that TPop3Client is    }
{ receiveing. This could be used to write the message lines to a file.      }
procedure TFPop.Pop3ClientMessageLine(Sender: TObject);
begin
    DisplayMemo.Lines.Add((Sender as TPop3Cli).LastResponse);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This event handler is called when TPop3Client is about to receive a       }
{ list line. The MsgNum property gives the message number.                  }
procedure TFPop.Pop3ClientListBegin(Sender: TObject);
begin
    DisplayMemo.Lines.Add('*** List begin ***');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This event handler is called when TPop3Client has received the last list  }
{ line.                                                                     }
procedure TFPop.Pop3ClientListEnd(Sender: TObject);
begin
    DisplayMemo.Lines.Add('*** List End ***');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This event handler is called for each list line received by TPop3Client.  }
procedure TFPop.Pop3ClientListLine(Sender: TObject);
var
    Buffer : String;
begin
    Buffer := 'MsgNum = ' + IntToStr((Sender as TPop3Cli).MsgNum) + ' ' +
              'MsgSize = ' + IntToStr((Sender as TPop3Cli).MsgSize) + ' ' +
              'Line = ''' + (Sender as TPop3Cli).LastResponse + '''';
    DisplayMemo.Lines.Add(Buffer);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.Pop3ClientUidlBegin(Sender: TObject);
begin
    DisplayMemo.Lines.Add('*** Uidl begin ***');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.Pop3ClientUidlEnd(Sender: TObject);
begin
    DisplayMemo.Lines.Add('*** Uidl end ***');
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.Pop3ClientUidlLine(Sender: TObject);
var
    Buffer : String;
begin
    Buffer := 'MsgNum = ' + IntToStr((Sender as TPop3Cli).MsgNum) + ' ' +
              'MsgUidl = ' + (Sender as TPop3Cli).MsgUidl + '''';
    DisplayMemo.Lines.Add(Buffer);
end;


procedure TFPop.retrClick(Sender: TObject);
begin
    Exec(Pop3Client.Retr, 'Retr');
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.MessageBegin(Sender: TObject);
begin
    MessageForm.Caption := 'Message ' +
                           IntToStr((Sender as TPop3Cli).MsgNum);
    MessageForm.Show;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.MessageLine(Sender: TObject);
begin
    MessageForm.DisplayMemo.Lines.Add((Sender as TPop3Cli).LastResponse);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.NextButtonClick(Sender: TObject);
begin
    MessageForm.DisplayMemo.Clear;
    MessageForm.Caption       := 'Message';
    Pop3Client.OnMessageBegin := MessageBegin;
    Pop3Client.OnMessageEnd   := nil;
    Pop3Client.OnMessageLine  := MessageLine;
    Pop3Client.OnRequestDone  := NextMessageRequestDone;
    Pop3Client.MsgNum         := StrToInt(MsgNumEdit.Text);
    Pop3Client.Retr;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.NextMessageRequestDone(
    Sender  : TObject;
    RqType  : TPop3Request;
    ErrCode : Word);
begin
    if ErrCode <> 0 then
        Exit;

    MsgNumEdit.Text := IntToStr(StrToInt(MsgNumEdit.Text) + 1);
end;


procedure TFPop.openClick(Sender: TObject);
begin
    Exec(Pop3Client.Open, 'Open');
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.GetAllMessageLine(Sender: TObject);
begin
    Writeln(FFile, (Sender as TPop3Cli).LastResponse);
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ The procedure here after will start an event chain that will eventually   }
{ download all messages for the POP3 server. We cannot simply loop because  }
{ the POP3 compomnet is asynchronous: it will not wait for operation done   }
{ before returning. We must "chain" operations one after the other using    }
{ the OnRequestDone event handler. We use the variable FGetAllState to keep }
{ track of where we are.                                                    }
{ To get all messages, we must first call Stat to know how many messages    }
{ are on the server, then for each message we call Uidl to get a unique     }
{ identifier for each message to build a file name and know if we already   }
{ have a message, then we retrieve the message, then we increment the       }
{ message number and continue until the number of messages is reached.      }
{ We should start a TTimer to handle timeout...                             }
procedure TFPop.GetAllButtonClick(Sender: TObject);
var
    IniFile : TIniFile;
begin
    { Get path from INI file }
    IniFile := TIniFile.Create(FIniFileName);
    FMsgPath    := IniFile.ReadString('Data', 'MsgPath',
                                  ExtractFilePath(Application.ExeName));
    IniFile.Free;

    { Be sure to have an ending backslash }
    if (Length(FMsgPath) > 0) and (FMsgPath[Length(FMsgPath)] <> '\') then
        FMsgPath := FMsgPath + '\';

    FGetAllState := 0;
    FFileOpened  := FALSE;
    Pop3Client.OnRequestDone  := GetAllRequestDone;
    Pop3Client.OnMessageBegin := nil;
    Pop3Client.OnMessageEnd   := nil;
    Pop3Client.OnMessageLine  := GetAllMessageLine;
    Pop3Client.Stat;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{ This event handler is called when a request related to GetAll is done.    }
{ We check for errors and our state variable FGetAllState which tells us    }
{ where we are (stat, uidl or retr which are the 4 commands we use.         }
{ Note that we also could use Dele to remove the messages from the server.  }
procedure TFPop.GetAllRequestDone(
    Sender  : TObject;
    RqType  : TPop3Request;
    ErrCode : Word);
begin
    if ErrCode <> 0 then begin
        if FFileOpened then begin
            FFileOpened := FALSE;
            CloseFile(FFile);
        end;
        DisplayMemo.Lines.Add('Error ' + Pop3Client.ErrorMessage);
        Exit;
    end;

    try
        case FGetAllState of
        0: begin     { Comes from the Stat command }
                if Pop3Client.MsgCount < 1 then begin
                    DisplayMemo.Lines.Add('No message to download.');
                    Exit;
                end;
                Pop3Client.MsgNum := 1;    { Start with first message }
                FGetAllState := 1;
                Pop3Client.Uidl;
           end;
        1: begin     { Comes from the Uidl command }
                FFileName := FMsgPath + 'Msg ' + Pop3Client.MsgUidl + '.txt';
                if FileExists(FFileName) then begin
                    DisplayMemo.Lines.Add('Message ' + IntToStr(Pop3Client.MsgNum) + ' already here');
                    if Pop3Client.MsgNum >= Pop3Client.MsgCount then begin
                        DisplayMemo.Lines.Add('Finished');
                        Exit;
                    end;
                    Pop3Client.MsgNum := Pop3Client.MsgNum + 1;
                    FGetAllState := 1;
                    Pop3Client.Uidl;
                end
                else begin
                    DisplayMemo.Lines.Add('Message ' + IntToStr(Pop3Client.MsgNum));
                    AssignFile(FFile, FFileName);
                    Rewrite(FFile);
                    FFileOpened  := TRUE;
                    FGetAllState := 2;
                    Pop3Client.Retr;
                end;
           end;
        2: begin     { Comes from the Retr command }
                FFileOpened := FALSE;
                CloseFile(FFile);
                if Pop3Client.MsgNum >= Pop3Client.MsgCount then begin
                    DisplayMemo.Lines.Add('Finished');
                    Exit;
                end;
                Pop3Client.MsgNum := Pop3Client.MsgNum + 1;
                FGetAllState := 1;
                Pop3Client.Uidl;
           end;
        else
            DisplayMemo.Lines.Add('Invalid state');
            Exit;
        end;
    except
        on E:Exception do begin
            if FFileOpened then begin
                FFileOpened := FALSE;
                CloseFile(FFile);
            end;
            DisplayMemo.Lines.Add('Error: ' + E.Message);
        end;
    end;
end;


procedure TFPop.listClick(Sender: TObject);
begin
    Exec(Pop3Client.List, 'List');
end;

procedure TFPop.lstallClick(Sender: TObject);
begin
    MsgNumEdit.Text := '0';
    Exec(Pop3Client.List, 'List All');
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.Pop3ClientRequestDone(
    Sender  : TObject;
    RqType  : TPop3Request;
    ErrCode : Word);
begin
    DisplayMemo.Lines.Add('Request Done Rq=' + IntToStr(Integer(RqType)) +
                          ' Error=' + IntToStr(ErrCode));

    if RqType = pop3Stat then begin
        InfoLabel.Caption := 'Stat ok, ' +
                             IntToStr(Pop3Client.MsgCount) + ' messages ' +
                             IntToStr(Pop3Client.MsgSize) + ' bytes'
    end
    else if RqType = pop3List then begin
        InfoLabel.Caption := 'List ok, ' +
                             IntToStr(Pop3Client.MsgNum)  + ' message ' +
                             IntToStr(Pop3Client.MsgSize) + ' bytes'
    end
    else if RqType = pop3Last then begin
        InfoLabel.Caption := 'Last = ' + IntToStr(Pop3Client.MsgNum);
    end;
end;


{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TFPop.Pop3ClientHeaderEnd(Sender: TObject);
begin
    SubjectEdit.Text := Pop3Client.HeaderSubject;
    FromEdit.Text    := Pop3Client.HeaderFrom;
    ToEdit.Text      := Pop3Client.HeaderTo;
end;

procedure TFPop.Exec(
    MethodPtr  : TPop3NextProc;
    MethodName : String);
begin
    SubjectEdit.Text          := '';
    FromEdit.Text             := '';
    ToEdit.Text               := '';

    Pop3Client.Host           := pophost.Text;
    Pop3Client.Port           := popport.Text;
    Pop3Client.UserName       := popusr.Text;
    Pop3Client.PassWord       := poppass.Text;
//    Pop3Client.AuthType       := TPop3AuthType(AuthComboBox.ItemIndex);
    Pop3Client.MsgNum         := StrToInt('1');
    Pop3Client.MsgLines       := StrToInt('0');
    { We need to reassign event handlers because we may have changed them }
    { doing GetAllMessages for example                                    }
    Pop3Client.OnRequestDone  := Pop3ClientRequestDone;
    Pop3Client.OnMessageBegin := Pop3ClientMessageBegin;
    Pop3Client.OnMessageEnd   := Pop3ClientMessageEnd;
    Pop3Client.OnMessageLine  := Pop3ClientMessageLine;
    InfoLabel.Caption         := MethodName + ' started';
    try
        MethodPtr;
        InfoLabel.Caption := MethodName + ' ok';
    except
        on E:Exception do begin
            MessageBeep(MB_OK);
            InfoLabel.Caption := MethodName + ' failed (' + E.Message + ')';
        end;
    end;
end;

end.

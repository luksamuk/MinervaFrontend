unit uFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, uFrmLogin,
  REST.Types, FMX.Controls.Presentation, FMX.StdCtrls, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope;

type
  TfrmPrincipal = class(TForm)
    frameLogin: TfrmLogin;
    RestCliente: TRESTClient;
    stbBarraStatus: TStatusBar;
    lblUsuarioLogado: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure frameLoginedtSenhaKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure frameLoginbtnEntrarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    mFrameAtual: TFrame;

    procedure RealizaLogin;
    procedure AbreCadastroCliente;
  public
     MUrlBase: String;
     MIdUsuario: Integer;
     MUsuario: String;
     MToken: String;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
   System.JSON, FMX.DialogService, uFrmCadCliente;

{$R *.fmx}
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}

procedure TfrmPrincipal.AbreCadastroCliente;
begin
   mFrameAtual := TfrmCadCliente.Create(Application);
   mFrameAtual.Parent := frmPrincipal;
   mFrameAtual.Align := TAlignLayout.Client;
   mFrameAtual.Visible := True;
   mFrameAtual.SetFocus;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
   MUrlBase := 'https://my-minerva-test.herokuapp.com/';
   MIdUsuario := 0;
   MUsuario := '';
   MToken := '';
   RestCliente.BaseURL := MUrlBase;
   frameLogin.edtLogin.SetFocus;
end;

procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
   if Key = vkReturn then
   begin
      Key := vkTab;
      KeyDown(Key, KeyChar, Shift);
   end;
end;

procedure TfrmPrincipal.frameLoginbtnEntrarClick(Sender: TObject);
begin
   RealizaLogin;
end;

procedure TfrmPrincipal.frameLoginedtSenhaKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
   if Key = vkReturn then
   begin
      Key := 0;
      frameLoginbtnEntrarClick(Sender);
   end;
end;

procedure TfrmPrincipal.RealizaLogin;
var
   xReq: TRESTRequest;
   xRes: TRESTResponse;
   xJson: TJSONObject;
   xJsonVal: TJSONValue;
begin
   xReq := nil;
   xRes := nil;

   xReq := TRESTRequest.Create(nil);
   xRes := TRESTResponse.Create(nil);
   xJson := TJSONObject.Create;

   xReq.Client := RestCliente;
   xReq.Response := xRes;

   xJson.AddPair('login', frameLogin.edtLogin.Text);
   xJson.AddPair('senha', frameLogin.edtSenha.Text);

   xReq.Method := rmPOST;
   xReq.AddParameter('Body', xJson, True);
   xReq.Resource := '/login';

   frameLogin.ProcessandoLogin := True;

   lblUsuarioLogado.Text := 'Realizando login...';
   xReq.ExecuteAsync(
      procedure
      begin
         try
            xJsonVal := xRes.JSONValue;
            if xRes.StatusCode <> 200 then
            begin
               frameLogin.ProcessandoLogin := False;
               TDialogService.ShowMessage(
                  'Erro ao realizar login:'#13 +
                  xJsonVal.GetValue<String>('mensagem'));

               lblUsuarioLogado.Text := EmptyStr;
               frameLogin.edtLogin.SetFocus;
               Exit;
            end;

            // Coleta dados do usuário recebidos como retorno
            // no login
            MIdUsuario := xJsonVal.GetValue<Integer>('id');
            MUsuario := xJsonVal.GetValue<String>('login');
            MToken := xJsonVal.GetValue<String>('token');

            frameLogin.Visible := False;

            lblUsuarioLogado.Text := IntToStr(MIdUsuario) + ' - ' + MUsuario;

            AbreCadastroCliente;
         finally
            if xReq <> nil then
               FreeAndNil(xReq);
         end;
      end,
      True,
      True,
      procedure(pError: TObject)
      var
         E: ERESTException;
      begin
         E := ERESTException(pError);
         frameLogin.ProcessandoLogin := False;
         TDialogService.ShowMessage(
            'Ocorreu um erro ao processar os dados de login:'#13 +
            E.Message);

         lblUsuarioLogado.Text := EmptyStr;
         frameLogin.edtLogin.SetFocus;

         if xReq <> nil then
            FreeAndNil(xReq);
      end);
end;

end.

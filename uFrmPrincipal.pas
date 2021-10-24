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
    mFrameMenu: TFrame;

    procedure RealizaLogin;
  public
     MUrlBase: String;

     constructor Create(Owner: TComponent); override;
     procedure AbreMenuPrincipal;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
   System.JSON, FMX.DialogService, uFrmMenu, uFrmCadCliente, uMinervaRequest,
   uMinervaS3;

{$R *.fmx}
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}

procedure TfrmPrincipal.AbreMenuPrincipal;
begin
   TMinervaS3.InicializaServico;
   if mFrameMenu = nil then
   begin
      mFrameMenu := TfrmMenu.Create(Application);
      mFrameMenu.Parent := frmPrincipal;
      mFrameMenu.Align := TAlignLayout.Client;
   end;
   mFrameMenu.Visible := True;
   mFrameMenu.Enabled := True;
   if mFrameMenu.CanFocus then
      mFrameMenu.SetFocus;
end;

constructor TfrmPrincipal.Create(Owner: TComponent);
begin
   inherited;
   mFrameMenu := nil;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
   MUrlBase := 'https://my-minerva-test.herokuapp.com/';

   RestCliente.BaseURL := MUrlBase;
   frameLogin.edtLogin.SetFocus;
   TMinervaRequest.get.Client := RestCliente;
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
begin
   FrameLogin.ProcessandoLogin := True;
   Application.ProcessMessages;

   TMinervaRequest.get.GetUserToken(
      frameLogin.edtLogin.Text,
      frameLogin.edtSenha.Text);

   FrameLogin.ProcessandoLogin := False;
   Application.ProcessMessages;

   if TMinervaRequest.get.LoginUsuario <> EmptyStr then
   begin
      lblUsuarioLogado.Text :=
         IntToStr(TMinervaRequest.get.IdUsuario) +
         ' - ' +
         TMinervaRequest.get.LoginUsuario;
      frameLogin.Visible := False;
      AbreMenuPrincipal;
   end
   else
      lblUsuarioLogado.Text := EmptyStr;
end;

end.

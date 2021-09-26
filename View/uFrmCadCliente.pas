unit uFrmCadCliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit;

type
  TfrmCadCliente = class(TFrame)
    lblTitulo: TLabel;
    edtNome: TEdit;
    grpTipoPessoa: TGroupBox;
    rdPessoaFisica: TRadioButton;
    rdPessoaJuridica: TRadioButton;
    edtCpfCnpj: TEdit;
    pnlBotoes: TPanel;
    pnlTipoPessoa: TPanel;
    btnVoltar: TButton;
    btnCadastrar: TButton;
    procedure btnVoltarClick(Sender: TObject);
    procedure btnCadastrarClick(Sender: TObject);
  private
    { Private declarations }
    mProcessando: Boolean;
    procedure setProcessando(Value: Boolean);
    procedure CadastraCliente;
    procedure LimpaTela;
  public
    { Public declarations }
    constructor Create(Owner: TComponent); override;

    property Processando: Boolean read mProcessando write setProcessando;
  end;

implementation

uses
   uFrmPrincipal, REST.Types, REST.Client, System.JSON, FMX.DialogService,
   StrUtils, uMinervaRequest;

{$R *.fmx}

procedure TfrmCadCliente.btnCadastrarClick(Sender: TObject);
begin
   CadastraCliente;
end;

procedure TfrmCadCliente.btnVoltarClick(Sender: TObject);
begin
   Self.Free;
   frmPrincipal.AbreMenuPrincipal;
end;

procedure TfrmCadCliente.CadastraCliente;
var
   xResposta: TRESTResponse;
   xBody: TJSONObject;
   xValores: TJSONValue;
   xMensagem: String;
begin
   xMensagem := EmptyStr;
   xBody := nil;
   try
      xBody := TJSONObject.Create;
      xBody.AddPair('nome', edtNome.Text);
      xBody.AddPair('pj', rdPessoaJuridica.IsChecked);
      xBody.AddPair('docto', edtCpfCnpj.Text);
      xBody.AddPair('enderecos', TJSONArray.Create);

      xResposta := TMinervaRequest.get.SyncRequest(rmPOST, '/clientes', xBody);

      if xResposta.StatusCode = 401 then
      begin
         TDialogService.ShowMessage('Erro no login do usuário.'#13);
         Exit;
      end;

      xValores := xResposta.JSONValue;

      if xResposta.StatusCode <> 200 then
      begin
         xValores.TryGetValue<String>('mensagem', xMensagem);
         TDialogService.ShowMessage(
            'Ocorreu um erro ao cadastrar o cliente'#13 +
             IfThen(xMensagem <> EmptyStr,
               xMensagem + ' (' + IntToStr(xResposta.StatusCode) + ')'));
         Exit;
      end;

      TDialogService.ShowMessage(
         'Cliente cadastrado com sucesso.'#13 +
         'ID: ' + IntToStr(xValores.GetValue<Integer>('id')));
      LimpaTela;
   finally
      if xBody <> nil then
         FreeAndNil(xBody);
   end;
end;

constructor TfrmCadCliente.Create(Owner: TComponent);
begin
   inherited;
   mProcessando := False;
end;

procedure TfrmCadCliente.LimpaTela;
begin
   edtNome.Text    := EmptyStr;
   edtCpfCnpj.Text := EmptyStr;
   rdPessoaFisica.IsChecked := True;
end;

procedure TfrmCadCliente.setProcessando(Value: Boolean);
begin
   mProcessando := Value;

   btnCadastrar.Enabled := not Value;
end;

end.

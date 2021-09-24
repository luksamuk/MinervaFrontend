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
    procedure LimpaTela;
  public
    { Public declarations }
    constructor Create(Owner: TComponent); override;

    property Processando: Boolean read mProcessando write setProcessando;
  end;

implementation

uses
   uFrmPrincipal, REST.Types, REST.Client, System.JSON, FMX.DialogService, StrUtils;

{$R *.fmx}

procedure TfrmCadCliente.btnCadastrarClick(Sender: TObject);
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

   xReq.Client := frmPrincipal.RestCliente;
   xReq.Response := xRes;

   xJson.AddPair('nome', edtNome.Text);
   xJson.AddPair('pj', rdPessoaJuridica.IsChecked);
   xJson.AddPair('docto', edtCpfCnpj.Text);
   xJson.AddPair('enderecos', TJSONArray.Create);

   xReq.Method := rmPOST;
   xReq.Params.AddItem('Authorization', 'Bearer ' + frmPrincipal.MToken,
      pkHTTPHEADER, [poDoNotEncode]);
   xReq.AddParameter('Body', xJson);
   xReq.Resource := '/clientes';

   Processando := True;

   xReq.ExecuteAsync(
      procedure
      var
         xMensagem: String;
      begin
         xMensagem := EmptyStr;
         try
            xJsonVal := xRes.JSONValue;

            if xRes.StatusCode = 401 then
            begin
               TDialogService.ShowMessage('Erro no login do usuário.'#13);
               Exit;
            end;

            if xRes.StatusCode <> 200 then
            begin
               xJsonVal.TryGetValue<String>('mensagem', xMensagem);
               TDialogService.ShowMessage(
                  'Ocorreu um erro ao cadastrar o cliente'#13 +
                   IfThen(xMensagem <> EmptyStr,
                     xMensagem + ' (' + IntToStr(xRes.StatusCode) + ')'));
               Exit;
            end;

            TDialogService.ShowMessage(
               'Cliente cadastrado com sucesso.'#13 +
               'ID: ' + IntToStr(xJsonVal.GetValue<Integer>('id')));
         finally
            if xReq <> nil then
               FreeAndNil(xReq);
            LimpaTela;
            Processando := False;
         end;
      end,
      True,
      True,
      procedure(pError: TObject)
      var
         E: ERESTException;
      begin
         E := ERESTException(pError);
         TDialogService.ShowMessage(
            'Ocorreu um erro ao cadastrar o cliente:'#13 +
            E.Message);
         Processando := False;

         if xReq <> nil then
            FreeAndNil(xReq);
      end);
end;

procedure TfrmCadCliente.btnVoltarClick(Sender: TObject);
begin
   Self.Free;
   frmPrincipal.AbreMenuPrincipal;
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

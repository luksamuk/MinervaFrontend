unit uFrmListaCliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, Data.DB, Datasnap.DBClient, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, REST.Types,
  REST.Client, System.JSON;

type
  TfrmListaCliente = class(TFrame)
    btnVoltar: TButton;
    lblTitulo: TLabel;
    grdClientes: TGrid;
    cdsClientes: TClientDataSet;
    bindGridClientes: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    pnlBotoes: TPanel;
    btnPesquisar: TButton;
    procedure btnVoltarClick(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
  private
    { Private declarations }
    procedure PopulaListaClientes(pJson: TJSONArray);
  public
    { Public declarations }
    procedure CarregaListaClientes;
  end;

implementation

uses
   uFrmPrincipal, FMX.DialogService, StrUtils;

{$R *.fmx}

procedure TfrmListaCliente.btnPesquisarClick(Sender: TObject);
begin
   CarregaListaClientes;
end;

procedure TfrmListaCliente.btnVoltarClick(Sender: TObject);
begin
   Self.Free;
   frmPrincipal.AbreMenuPrincipal;
end;

procedure TfrmListaCliente.CarregaListaClientes;
var
   xReq: TRESTRequest;
   xRes: TRESTResponse;
begin
   xReq := TRESTRequest.Create(nil);
   xRes := TRESTResponse.Create(nil);

   xReq.Client := frmPrincipal.RestCliente;
   xReq.Response := xRes;

   xReq.Method := rmGET;
   xReq.Params.AddItem('Authorization', 'Bearer ' + frmPrincipal.MToken,
      pkHTTPHEADER, [poDoNotEncode]);
   xReq.Resource := '/clientes';

   btnPesquisar.Enabled := False;

   xReq.ExecuteAsync(
      procedure
      var
         xMensagem: String;
         xJsonVal: TJSONValue;
      begin
         xMensagem := EmptyStr;
         try
            if xRes.StatusCode = 401 then
            begin
               TDialogService.ShowMessage('Erro no login do usuário.'#13);
               Exit;
            end;

            xJsonVal := xRes.JSONValue;

            if xRes.StatusCode <> 200 then
            begin
               xJsonVal.TryGetValue<String>('mensagem', xMensagem);
               TDialogService.ShowMessage(
                  'Ocorreu um erro ao pesquisar clientes'#13 +
                   IfThen(xMensagem <> EmptyStr,
                     xMensagem + ' (' + IntToStr(xRes.StatusCode) + ')'));
               Exit;
            end;

            PopulaListaClientes(TJSONArray(xJsonVal));
         finally
            if xReq <> nil then
               FreeAndNil(xReq);
            btnPesquisar.Enabled := True;
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
            'Ocorreu um erro ao pesquisar clientes:'#13 +
            E.Message);

         if xReq <> nil then
            FreeAndNil(xReq);
         btnPesquisar.Enabled := True;
      end);
end;

procedure TfrmListaCliente.PopulaListaClientes(pJson: TJSONArray);
var
   xObj: TJSONValue;
begin
   cdsClientes.EmptyDataSet;
   for xObj in pJson do
   begin
      cdsClientes.Append;
      cdsClientes.FieldByName('ID').AsInteger        := xObj.GetValue<Integer>('id');
      cdsClientes.FieldByName('Nome').AsString       := xObj.GetValue<String>('nome');
      cdsClientes.FieldByName('PJ').AsBoolean        := xObj.GetValue<Boolean>('pj');
      cdsClientes.FieldByName('Documento').AsString  := xObj.GetValue<String>('docto');
      cdsClientes.FieldByName('Ativo').AsBoolean     := xObj.GetValue<Boolean>('ativo');
      cdsClientes.FieldByName('Bloqueado').AsBoolean := xObj.GetValue<Boolean>('bloqueado');
      cdsClientes.Post;
   end;
end;

end.

unit uFrmListaCliente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, Data.DB, Datasnap.DBClient, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope, REST.Types,
  REST.Client, System.JSON, FMX.frxClass, FMX.frxDBSet;

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
    frxListagemCliente: TfrxReport;
    btnListar: TButton;
    frxDBListagemCliente: TfrxDBDataset;
    btnExcluir: TButton;
    procedure btnVoltarClick(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnListarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure grdClientesDrawColumnCell(Sender: TObject; const Canvas: TCanvas;
      const Column: TColumn; const Bounds: TRectF; const Row: Integer;
      const Value: TValue; const State: TGridDrawStates);
  private
    { Private declarations }
    procedure PopulaListaClientes(pJson: TJSONArray);
  public
    { Public declarations }
    procedure CarregaListaClientes;
  end;

implementation

uses
   uFrmPrincipal, FMX.DialogService, StrUtils, uMinervaRequest;

{$R *.fmx}

procedure TfrmListaCliente.btnExcluirClick(Sender: TObject);
var
   xResposta: TRESTResponse;
   xID: String;
begin
   if cdsClientes.IsEmpty then
   begin
      TDialogService.ShowMessage('Não há clientes listados.');
      Exit;
   end;

   xID := cdsClientes.FieldByName('ID').AsString;

   TDialogService.MessageDialog(
      'Deseja deletar o cliente de ID ' + xID + '?',
      TMsgDlgType.mtConfirmation,
      FMX.Dialogs.mbYesNo,
      TMsgDlgBtn.mbNo,
      0,
      procedure(const pResult: TModalResult)
      var
         xJson: TJSONValue;
      begin
         case pResult of
         mrYes:
            begin
               xResposta := TMinervaRequest.get.SyncRequest(
                  rmDELETE, '/clientes/' + xID);

               xJson := xResposta.JSONValue;

               if xResposta.StatusCode <> 200 then
               begin
                  TDialogService.ShowMessage(
                     'Erro ao deletar cliente:'#13 +
                     xJson.GetValue<String>('mensagem'));
                  Exit;
               end;

               cdsClientes.Delete;

               TDialogService.ShowMessage(
                  'Cliente deletado. ID: ' +
                  IntToStr(xJson.GetValue<Integer>('id')));
            end;
         mrNo: Exit;
         end;
      end);
end;

procedure TfrmListaCliente.btnListarClick(Sender: TObject);
begin
   if cdsClientes.IsEmpty then
   begin
      TDialogService.ShowMessage('Não há dados para serem mostrados.');
      Exit;
   end;
   frxListagemCliente.ShowReport;
end;

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
   xResposta: TRESTResponse;
   xValores: TJSONValue;
   xMensagem: String;
begin
   xMensagem := EmptyStr;
   xResposta := TMinervaRequest.get.SyncRequest(rmGET, '/clientes');

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
         'Ocorreu um erro ao pesquisar clientes'#13 +
          IfThen(xMensagem <> EmptyStr,
            xMensagem + ' (' + IntToStr(xResposta.StatusCode) + ')'));
      Exit;
   end;

   PopulaListaClientes(TJSONArray(xValores));
end;

procedure TfrmListaCliente.grdClientesDrawColumnCell(Sender: TObject;
  const Canvas: TCanvas; const Column: TColumn; const Bounds: TRectF;
  const Row: Integer; const Value: TValue; const State: TGridDrawStates);
var
   xWidth: Single;
begin
   xWidth := 5 + Canvas.TextWidth(Value.ToString);
   if xWidth > Column.Width then
      Column.Width := xWidth;
end;

procedure TfrmListaCliente.PopulaListaClientes(pJson: TJSONArray);
var
   xObj: TJSONValue;
   xArray: TJSONArray;
   xAux: TJSONValue;
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

      xArray := xObj.GetValue<TJSONArray>('enderecos');
      if xArray.Count > 0 then
      begin
         xAux := xArray.Items[0];
         cdsClientes.FieldByName('Logradouro').AsString  := xAux.GetValue<String>('logradouro');
         cdsClientes.FieldByName('Numero').AsString      := xAux.GetValue<String>('numero');
         cdsClientes.FieldByName('Complemento').AsString := xAux.GetValue<String>('complemento');
         cdsClientes.FieldByName('Bairro').AsString      := xAux.GetValue<String>('bairro');
         cdsClientes.FieldByName('UF').AsString          := xAux.GetValue<String>('uf');
         cdsClientes.FieldByName('Cidade').AsString      := xAux.GetValue<String>('cidade');
      end;

      cdsClientes.Post;
   end;
end;

end.

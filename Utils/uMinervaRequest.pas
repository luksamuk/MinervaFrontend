unit uMinervaRequest;

interface

uses REST.Types, REST.Client, System.JSON;

type
   TMinervaRequest = class
   private
      mClient: TRESTClient;
      mToken: String;
      mIdUsuario: Integer;
      mLoginUsuario: String;
      constructor Create;
   public
      property Client: TRESTClient read mClient write mClient;
      property IdUsuario: Integer read mIdUsuario;
      property LoginUsuario: String read mLoginUsuario;

      class function get: TMinervaRequest;
      procedure GetUserToken(pLogin, pSenha: String);
      function SyncRequest(pMethod: TRESTRequestMethod; pRoute: String;
        pBody: TJSONObject = nil;
        pAuthorized: Boolean = True): TRESTResponse;
   end;

var
   _MinervaRequest: TMinervaRequest;

implementation

uses
   SysUtils, FMX.DialogService, System.UITypes;

{ TMinervaRequest }

constructor TMinervaRequest.Create;
begin
   mToken        := EmptyStr;
   mIdUsuario    := -1;
   mLoginUsuario := EmptyStr;
end;

class function TMinervaRequest.get: TMinervaRequest;
begin
   if not Assigned(_MinervaRequest) then
      _MinervaRequest := TMinervaRequest.Create;
   Result := _MinervaRequest;
end;

procedure TMinervaRequest.GetUserToken(pLogin, pSenha: String);
var
   xResposta: TRESTResponse;
   xBody: TJSONObject;
   xJson: TJSONValue;
begin
   xBody := nil;
   try
      xBody := TJSONObject.Create;
      xBody.AddPair('login', pLogin);
      xBody.AddPair('senha', pSenha);
      xResposta := SyncRequest(rmPOST, '/login', xBody, False);

      xJson := xResposta.JSONValue;

      if xResposta.StatusCode <> 200 then
      begin
         TDialogService.ShowMessage(
            'Erro ao realizar login:'#13 +
            xJson.GetValue<String>('mensagem') +
            ' (' + IntToStr(xResposta.StatusCode) + ')');
         Exit;
      end;

      mIdUsuario    := xJson.GetValue<Integer>('id');
      mLoginUsuario := xJson.GetValue<String>('login');
      mToken        := xJson.GetValue<String>('token');
   finally
      if xBody <> nil then
         FreeAndNil(xBody);
   end;
end;

function TMinervaRequest.SyncRequest(pMethod: TRESTRequestMethod;
  pRoute: String; pBody: TJSONObject;
  pAuthorized: Boolean): TRESTResponse;
var
   xRequest: TRESTRequest;
   xRetorno: TRESTResponse;
   xLock: Boolean;
begin
   xRequest := TRESTRequest.Create(nil);
   xRetorno := TRESTResponse.Create(nil);
   xLock    := False;

   xRequest.Client   := Self.mClient;
   xRequest.Response := xRetorno;
   xRequest.Method   := pMethod;
   xRequest.Resource := pRoute;

   if pAuthorized then
      xRequest.Params.AddItem(
         'Authorization', 'Bearer ' + mToken, pkHTTPHeader, [poDoNotEncode]);

   if pBody <> nil then
      xRequest.AddParameter(
         'Body', TJSONObject(TJSONObject.ParseJSONValue(pBody.ToJSON)));

   xRequest.Execute;

   if pAuthorized and (xRetorno.StatusCode = 401) then
   begin
      // Se a requisição não foi autorizada, provavelmente o token
      // de acesso expirou. Peça para fazer login de novo.
      xLock := True;
      TDialogService.InputQuery(
         'Faça login novamente',
         ['Login:', #1'Senha:'], [mLoginUsuario, ''],
         procedure(const pResultado: TModalResult; const pValores: array of string)
         var
            xNovoRetorno: TRESTResponse;
         begin
            if pResultado = mrCancel then
            begin
               xLock := False;
               Exit;
            end;

            GetUserToken(pValores[0], pValores[1]);
            xNovoRetorno := SyncRequest(pMethod, pRoute, pBody, pAuthorized);
            FreeAndNil(xRetorno);
            xRetorno := xNovoRetorno;
            xLock := False;
         end);
   end;

   // Spinlock aguardando a execução da continuation
   // de nova tentativa de login
   while xLock do
      Sleep(500);

   Result := xRetorno;
end;

end.

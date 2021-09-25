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
         pBody: TJSONObject = nil; pAuthorized: Boolean = True): TRESTResponse;
   end;

var
   _MinervaRequest: TMinervaRequest;

implementation

uses
   SysUtils, FMX.DialogService;

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
      //FreeAndNil(xBody);
      //FreeAndNil(xResposta);
   end;
end;

function TMinervaRequest.SyncRequest(pMethod: TRESTRequestMethod;
  pRoute: String; pBody: TJSONObject;
  pAuthorized: Boolean): TRESTResponse;
var
   xRequest: TRESTRequest;
begin
   xRequest := TRESTRequest.Create(nil);
   Result   := TRESTResponse.Create(nil);

   xRequest.Client   := Self.mClient;
   xRequest.Response := Result;
   xRequest.Method   := pMethod;
   xRequest.Resource := pRoute;

   if pAuthorized then
      xRequest.Params.AddItem(
         'Authorization', 'Bearer ' + mToken, pkHTTPHeader, [poDoNotEncode]);

   if pBody <> nil then
      xRequest.AddParameter('Body', pBody);

   xRequest.Execute;
end;

end.

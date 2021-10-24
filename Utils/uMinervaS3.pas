unit uMinervaS3;

interface

type
   TMinervaS3 = class
   public
      class procedure InicializaServico;
      class procedure UploadArquivo(const pCaminho: string);
      class procedure DeletaArquivo(const pNome: string);
      class procedure DownloadArquivo(const pNome: string);
   end;

implementation

uses
   Amazon.Storage.Service, System.IniFiles, System.SysUtils;

{ TMinervaS3 }

class procedure TMinervaS3.DeletaArquivo(const pNome: string);
begin
   TAmazonStorageService.New.DeleteFile(pNome);
end;

class procedure TMinervaS3.DownloadArquivo(const pNome: string);
begin
   TAmazonStorageService.New.DownloadFile(pNome);
end;

class procedure TMinervaS3.InicializaServico;
var
   xIni: TIniFile;
begin
   xIni := nil;
   try
      xIni := TIniFile.Create('C:\Minerva\MinervaFrontend.ini');
      with TAmazonStorageServiceConfig.GetInstance do
      begin
         AccessKey      := xIni.ReadString('S3', 'AccessKey', '');
         SecretKey      := xIni.ReadString('S3', 'SecretKey', '');
         Region         := TAmazonRegion.amzrSAEast1; // São Paulo
         Protocol       := TAmazonProtocol.https;
         MainBucketName := xIni.ReadString('S3', 'BucketName', '');
      end;
   finally
      if xIni <> nil then
         FreeAndNil(xIni);
   end;
end;

class procedure TMinervaS3.UploadArquivo(const pCaminho: string);
begin
   TAmazonStorageService.New.UploadFile(pCaminho);
end;

end.

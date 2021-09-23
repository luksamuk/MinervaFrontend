program MinervaFrontend;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFrmPrincipal in 'uFrmPrincipal.pas' {frmPrincipal},
  uFrmLogin in 'View\uFrmLogin.pas' {frmLogin: TFrame},
  uFrmCadCliente in 'View\uFrmCadCliente.pas' {frmCadCliente: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.

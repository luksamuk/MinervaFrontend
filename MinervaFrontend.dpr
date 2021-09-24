program MinervaFrontend;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFrmPrincipal in 'uFrmPrincipal.pas' {frmPrincipal},
  uFrmLogin in 'View\uFrmLogin.pas' {frmLogin: TFrame},
  uFrmCadCliente in 'View\uFrmCadCliente.pas' {frmCadCliente: TFrame},
  uFrmMenu in 'View\uFrmMenu.pas' {frmMenu: TFrame},
  uFrmListaCliente in 'View\uFrmListaCliente.pas' {frmListaCliente: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.

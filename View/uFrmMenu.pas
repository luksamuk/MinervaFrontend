unit uFrmMenu;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation;

type
  TfrmMenu = class(TFrame)
    btnCadastraCliente: TButton;
    btnListaClientes: TButton;
    procedure btnCadastraClienteClick(Sender: TObject);
    procedure btnListaClientesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AbreCadastroCliente;
    procedure AbreListaCliente;
  end;

implementation

uses
   uFrmPrincipal, uFrmCadCliente, uFrmListaCliente;

{$R *.fmx}

procedure TfrmMenu.AbreCadastroCliente;
var
   xFrame: TFrame;
begin
   xFrame := TfrmCadCliente.Create(Application);
   xFrame.Parent := frmPrincipal;
   xFrame.Align := TAlignLayout.Client;
   xFrame.Visible := True;

   if xFrame.CanFocus then
      xFrame.SetFocus;
end;

procedure TfrmMenu.AbreListaCliente;
var
   xFrame: TFrame;
begin
   xFrame := TfrmListaCliente.Create(Application);
   xFrame.Parent := frmPrincipal;
   xFrame.Align := TAlignLayout.Client;
   xFrame.Visible := True;

   if xFrame.CanFocus then
      xFrame.SetFocus;
end;

procedure TfrmMenu.btnCadastraClienteClick(Sender: TObject);
begin
   Self.Enabled := False;
   Self.Visible := False;
   AbreCadastroCliente;
end;

procedure TfrmMenu.btnListaClientesClick(Sender: TObject);
begin
   Self.Enabled := False;
   Self.Visible := False;
   AbreListaCliente;
end;

end.

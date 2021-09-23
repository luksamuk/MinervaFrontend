unit uFrmLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.Colors, FMX.Objects;

type
  TfrmLogin = class(TFrame)
    Layout: TLayout;
    edtLogin: TEdit;
    edtSenha: TEdit;
    btnEntrar: TButton;
    rectBackground: TRectangle;
  private
    mProcLogin: Boolean;
    procedure setProcessandoLogin(Value: Boolean);
  public
    constructor Create(Owner: TComponent); override;
    property ProcessandoLogin: Boolean read mProcLogin write setProcessandoLogin;
  end;

implementation

{$R *.fmx}

{ TfrmLogin }

constructor TfrmLogin.Create(Owner: TComponent);
begin
   inherited;
   mProcLogin := False;
end;

procedure TfrmLogin.setProcessandoLogin(Value: Boolean);
begin
   mProcLogin := Value;
   btnEntrar.Enabled := not Value;
   edtLogin.Enabled  := not Value;
   edtSenha.Enabled  := not Value;
end;

end.

tableextension 91100 "DIMA General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(91100; "Totals Currency Code"; Code[10])
        {
            Caption = 'Cod. Divisa';
            ToolTip = 'Divisa en la que mostrará los Totales Debe y Haber div.-adic. dentro de movs. contabilidad vista previa y Diario General.';
            TableRelation = "Currency";
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}
pageextension 91105 "DIMA General Ledger Setup Ext" extends "General Ledger Setup"
{
    layout
    {
        addafter("Electronic Invoice")
        {
            group("DIMA General Ledger Setup")
            {
                Caption = 'Movs. Contabilidad';

                field("Totals Currency Code"; Rec."Totals Currency Code")
                {
                    Caption = 'Divisa';
                    ApplicationArea = All;
                }
            }
        }
    }
}
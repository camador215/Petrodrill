pageextension 91102 "Value Entries Ext" extends "Value Entries"
{
    layout
    {
        addafter(Control1)
        {
            group(Totals)
            {
                ShowCaption = false;

                group(ImporteCostoEsperado)
                {
                    ShowCaption = false;

                    field("Total Importe Costo Esperado"; TotalImporteCostoEsperado)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = true;
                        DecimalPlaces = 2 : 2;
                    }
                }

                group(ImporteCostoReal)
                {
                    ShowCaption = false;

                    field("Total Importe Costo Real"; TotalImporteCostoReal)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = true;
                        DecimalPlaces = 2 : 2;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CalculateTotals();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalculateTotals();
    end;

    var
        TotalImporteCostoEsperado: Decimal;
        TotalImporteCostoReal: Decimal;

    local procedure CalculateTotals()
    var
        ValueEntry: Record "Value Entry";
    begin
        TotalImporteCostoEsperado := 0;
        TotalImporteCostoReal := 0;

        ValueEntry.Copy(Rec, false);

        if ValueEntry.FindSet() then
            repeat
                TotalImporteCostoEsperado += ValueEntry."Cost Amount (Expected)";
                TotalImporteCostoReal += ValueEntry."Cost Amount (Actual)";
            until ValueEntry.Next() = 0;
    end;
}
pageextension 91101 "DIMA General Journal" extends "General Journal"
{
    layout
    {
        addbefore(amount)
        {
            field("Debe LCY"; Rec."Debit Amount")
            {
                ApplicationArea = All;
                Editable = true;
                Visible = true;
                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    CalculateTotals();
                end;
            }

            field("Haber LCY"; Rec."Credit Amount")
            {
                ApplicationArea = All;
                Editable = true;
                Visible = true;
                trigger OnValidate()
                begin
                    CurrPage.SaveRecord();
                    CalculateTotals();
                end;
            }
        }
        addbefore(Control30)
        {

            group(Totales)
            {
                ShowCaption = false;
                field("Total importe debe"; TotalDebe)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                }
                field("Total importe haber"; TotalHaber)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        CalculateTotals();
    end;

    trigger OnAfterGetRecord()
    begin
        CalculateTotals();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalculateTotals();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CalculateTotals();
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CalculateTotals();
        exit(true);
    end;

    var
        TotalDebe: Decimal;
        TotalHaber: Decimal;

    local procedure CalculateTotals()
    var
        GLJournalLine: Record "Gen. Journal Line";
    begin
        TotalDebe := 0;
        TotalHaber := 0;

        GLJournalLine.Copy(Rec, false);

        if GLJournalLine.FindSet() then
            repeat
                TotalDebe += GLJournalLine."Debit Amount";
                TotalHaber += GLJournalLine."Credit Amount";
            until GLJournalLine.Next() = 0;
    end;
}
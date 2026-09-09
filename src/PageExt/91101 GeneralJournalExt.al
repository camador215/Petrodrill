pageextension 91101 "DIMA General Journal" extends "General Journal"
{
    layout
    {
        modify("Currency Code")
        {
            ApplicationArea = All;
            Visible = true;
        }
        modify("Debit Amount")
        {
            ApplicationArea = All;
            Editable = true;
            Visible = true;
            trigger OnAfterValidate()
            begin
                CalculateTotals();
            end;
        }

        modify("Credit Amount")
        {
            ApplicationArea = All;
            Editable = true;
            Visible = true;
            trigger OnAfterValidate()
            begin
                CalculateTotals();
            end;
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
            group(TotalesACY)
            {
                ShowCaption = false;
                field("Total Debe div.-adic."; TotalDebeACY)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                }
                field("Total Haber div.-adic."; TotalHaberACY)
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
        TotalDebeACY: Decimal;
        TotalHaberACY: Decimal;


    local procedure CalculateTotals()
    var
        GLJournalLine: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        CurrencyTotals: Code[10];
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        TotalDebe := 0;
        TotalHaber := 0;
        TotalDebeACY := 0;
        TotalHaberACY := 0;

        GLJournalLine.Copy(Rec, false);
        GLSetup.Get();
        CurrencyTotals := GLSetup."Totals Currency Code";

        if GLJournalLine.FindSet() then
            repeat
                if GLJournalLine."Amount (LCY)" > 0 then
                    TotalDebe += GLJournalLine."Amount (LCY)"
                else
                    TotalHaber += Abs(GLJournalLine."Amount (LCY)");

                if CurrencyTotals <> '' then begin
                    if GLJournalLine."Amount (LCY)" > 0 then
                        TotalDebeACY += CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                            WorkDate(),
                            CurrencyTotals,
                            GLJournalLine."Amount (LCY)",
                            CurrencyExchangeRate.ExchangeRate(
                                WorkDate(),
                                CurrencyTotals
                            )
                        )
                    else
                        TotalHaberACY += CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                                WorkDate(),
                                CurrencyTotals,
                                Abs(GLJournalLine."Amount (LCY)"),
                                CurrencyExchangeRate.ExchangeRate(
                                    WorkDate(),
                                    CurrencyTotals
                                )
                            )
                end else begin
                    if GLJournalLine."Amount (LCY)" > 0 then
                        TotalDebeACY += GLJournalLine."Amount (LCY)"
                    else
                        TotalHaberACY += Abs(GLJournalLine."Amount (LCY)");
                end;

            until GLJournalLine.Next() = 0;
    end;
}
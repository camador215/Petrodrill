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
                    CaptionClass = GetCaptionWithCurrencyCode('Total importe debe', '');
                    DecimalPlaces = 2 : 2;
                    ToolTip = 'Especifica la suma del valor del campo "Importe debe" en todas las líneas del documento.';
                }
                field("Total importe haber"; TotalHaber)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                    DecimalPlaces = 2 : 2;
                    CaptionClass = GetCaptionWithCurrencyCode('Total importe haber', '');
                    ToolTip = 'Especifica la suma del valor del campo "Importe haber" en todas las líneas del documento.';
                }
            }
            group(TotalesACY)
            {
                ShowCaption = false;
                field("Total Debe div.-adic."; TotalDebeACY)
                {
                    ApplicationArea = All;
                    Editable = false;
                    CaptionClass = GetCaptionWithCurrencyCode('Total debe div.-adic.', 'ACY');
                    Visible = ShowTotalACY;
                    DecimalPlaces = 2 : 2;
                    ToolTip = 'Especifica la suma del valor del campo "Importe debe" de todas las líneas del documento, expresada en la divisa definida en Configuración de contabilidad, en el grupo Movs. contabilidad.';
                }
                field("Total Haber div.-adic."; TotalHaberACY)
                {
                    ApplicationArea = All;
                    Editable = false;
                    CaptionClass = GetCaptionWithCurrencyCode('Total haber div.-adic.', 'ACY');
                    Visible = ShowTotalACY;
                    DecimalPlaces = 2 : 2;
                    ToolTip = 'Especifica la suma del valor del campo "Importe haber" de todas las líneas del documento, expresada en la divisa definida en Configuración de contabilidad, en el grupo Movs. contabilidad.';
                }
            }

        }
    }
    trigger OnOpenPage()
    begin
        GLSetup.Get();
        ShowTotalsACY();
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
        ShowTotalACY: Boolean;
        GLSetup: Record "General Ledger Setup";


    local procedure CalculateTotals()
    var
        GLJournalLine: Record "Gen. Journal Line";
        CurrencyTotals: Code[10];
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        TotalDebe := 0;
        TotalHaber := 0;
        TotalDebeACY := 0;
        TotalHaberACY := 0;

        GLJournalLine.Copy(Rec, false);
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
                            GLJournalLine."Posting Date",
                            CurrencyTotals,
                            GLJournalLine."Amount (LCY)",
                            CurrencyExchangeRate.ExchangeRate(
                                GLJournalLine."Posting Date",
                                CurrencyTotals
                            )
                        )
                    else
                        TotalHaberACY += CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                                GLJournalLine."Posting Date",
                                CurrencyTotals,
                                Abs(GLJournalLine."Amount (LCY)"),
                                CurrencyExchangeRate.ExchangeRate(
                                    GLJournalLine."Posting Date",
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

    local procedure GetCaptionWithCurrencyCode(CaptionWithoutCurrencyCode: Text; CurrencyCode: Text): Text
    begin
        if CurrencyCode = '' then
            CurrencyCode := GLSetup.GetCurrencyCode(CurrencyCode)
        else
            CurrencyCode := GLSetup."Totals Currency Code";

        if CurrencyCode <> '' then
            exit(CaptionWithoutCurrencyCode + StrSubstNo(' (%1)', CurrencyCode));

        exit(CaptionWithoutCurrencyCode);
    end;

    local procedure ShowTotalsACY()
    var
        CurrencyACY: Code[10];
    begin
        ShowTotalACY := GLSetup."Totals Currency Code" <> '';
    end;
}
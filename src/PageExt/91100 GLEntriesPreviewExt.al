pageextension 91100 "DIMA G/L Entries Preview" extends "G/L Entries Preview"
{
    layout
    {
        modify(Amount)
        {
            visible = false;
        }
        modify("Source Currency Amount")
        {
            visible = false;
        }
        modify("Debit Amount")
        {
            Editable = false;
            Visible = true;
        }

        modify("Credit Amount")
        {
            Editable = false;
            Visible = true;
        }
        addafter(Control1)
        {
            group(Totals)
            {
                ShowCaption = false;

                group(LCY)
                {
                    ShowCaption = false;

                    field("Total importe debe"; TotalDebeLCY)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = true;
                        CaptionClass = GetCaptionWithCurrencyCode('Total importe debe', '');
                        DecimalPlaces = 2 : 2;
                        ToolTip = 'Especifica la suma del valor del campo "Importe debe" en todas las líneas de esta vista previa.';
                    }
                    field("Total Debe div.-adic."; TotalDebeACY)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        CaptionClass = GetCaptionWithCurrencyCode('Total debe div.-adic.', 'ACY');
                        Visible = ShowTotalACY;
                        DecimalPlaces = 2 : 2;
                        ToolTip = 'Especifica la suma del valor del campo "Importe debe" de todas las líneas de esta vista previa, expresada en la divisa definida en Configuración de contabilidad, en el grupo Movs. contabilidad.';
                    }
                }

                group(ACY)
                {
                    ShowCaption = false;

                    field("Total importe haber"; TotalHaberLCY)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = true;
                        CaptionClass = GetCaptionWithCurrencyCode('Total importe haber', '');
                        DecimalPlaces = 2 : 2;
                        ToolTip = 'Especifica la suma del valor del campo "Importe haber" en todas las líneas de esta vista previa.';
                    }
                    field("Total haber div.-adic."; TotalHaberACY)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        CaptionClass = GetCaptionWithCurrencyCode('Total haber div.-adic.', 'ACY');
                        Visible = ShowTotalACY;
                        DecimalPlaces = 2 : 2;
                        ToolTip = 'Especifica la suma del valor del campo "Importe haber" de todas las líneas de esta vista previa, expresada en la divisa definida en Configuración de contabilidad, en el grupo Movs. contabilidad.';
                    }
                }
            }

        }

    }

    actions
    {
        addlast(Processing)
        {
            action(DIMARegister)
            {
                ApplicationArea = All;
                Caption = 'Registrar';
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Process;
                // Enabled = false;
                ToolTip = '(En Mantenimiento...). Registra el documento que originó esta previsualización.';

                trigger OnAction()
                var
                    PreviewContext: Codeunit "DIMA Preview Context";
                    Subscriber: Variant;
                    RecVar: Variant;
                    PreviewId: Guid;
                    RecRef: RecordRef;
                    CodeunitId: Integer;
                    ImpAsientosContables: Codeunit "DIMA Imp. Asientos Contables";
                begin
                    PreviewId :=
                        PreviewContext.GetContext(
                            Subscriber,
                            RecVar);

                    if IsNullGuid(PreviewId) then
                        Error('No existe un contexto de Preview activo.');

                    if RecVar.IsRecord() then
                        RecRef.GetTable(RecVar);

                    CodeunitId := GetPostingCodeunit(RecRef);

                    if CodeunitId = 0 then
                        Error('No existe un Codeunit configurado para la tabla %1.', RecRef.Caption());

                    Codeunit.Run(CodeunitId, RecVar);

                    if CodeunitId = Codeunit::"Item Jnl.-Post" then begin
                        PreviewContext.RequestRegister();
                        ImpAsientosContables.ImprimirAsientoContable(RecRef);
                    end;

                    if PreviewContext.IsRegisterRequested() then
                        CurrPage.Close();

                    // if Codeunit.Run(CodeunitId, RecVar) then begin
                    //     PreviewContext.RequestRegister();
                    //     CurrPage.Close();
                    // end;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        GLSetup.Get();
        ShowTotalsACY();
        CalculateTotals();
    end;

    var
        TotalDebeLCY: Decimal;
        TotalHaberLCY: Decimal;
        TotalDebeACY: Decimal;
        TotalHaberACY: Decimal;
        ShowTotalACY: Boolean;
        GLSetup: Record "General Ledger Setup";


    local procedure CalculateTotals()
    var
        GLEntry: Record "G/L Entry" temporary;
        GLSetup: Record "General Ledger Setup";
        CurrencyTotals: Code[10];
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        TotalDebeLCY := 0;
        TotalHaberLCY := 0;
        TotalDebeACY := 0;
        TotalHaberACY := 0;

        GLEntry.Copy(Rec, true);

        GLSetup.Get();
        CurrencyTotals := GLSetup."Totals Currency Code";

        if GLEntry.FindSet() then
            repeat
                if GLEntry."Amount" > 0 then
                    TotalDebeLCY += GLEntry."Amount"
                else
                    TotalHaberLCY += Abs(GLEntry."Amount");

                if CurrencyTotals <> '' then begin
                    if GLEntry."Amount" > 0 then
                        TotalDebeACY += CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                            GLEntry."Posting Date",
                            CurrencyTotals,
                            GLEntry."Amount",
                            CurrencyExchangeRate.ExchangeRate(
                                GLEntry."Posting Date",
                                CurrencyTotals
                            )
                        )
                    else
                        TotalHaberACY += CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                                GLEntry."Posting Date",
                                CurrencyTotals,
                                Abs(GLEntry."Amount"),
                                CurrencyExchangeRate.ExchangeRate(
                                    GLEntry."Posting Date",
                                    CurrencyTotals
                                )
                            )
                end else begin
                    if GLEntry."Amount" > 0 then
                        TotalDebeACY += GLEntry."Amount"
                    else
                        TotalHaberACY += Abs(GLEntry."Amount");
                end;
            until GLEntry.Next() = 0;
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

    local procedure GetPostingCodeunit(RecRef: RecordRef): Integer
    begin
        case RecRef.Number() of
            Database::"Sales Header":
                exit(Codeunit::"Sales-Post (Yes/No)");

            Database::"Purchase Header":
                exit(Codeunit::"Purch.-Post (Yes/No)");

            Database::"Gen. Journal Line":
                exit(Codeunit::"Gen. Jnl.-Post");

            Database::"Item Journal Line":
                exit(Codeunit::"Item Jnl.-Post");

            Database::"FA Journal Line":
                exit(Codeunit::"FA. Jnl.-Post");
        end;

        exit(0);
    end;
}
pageextension 91100 "DIMA G/L Entries Preview" extends "G/L Entries Preview"
{
    layout
    {
        addafter(Amount)
        {
            field("Debe LCY"; Rec."Debit Amount")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = true;
            }

            field("Haber LCY"; Rec."Credit Amount")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = true;
            }

            field("Debe ACY"; Rec."Add.-Currency Debit Amount")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = true;
            }

            field("Haber ACY"; Rec."Add.-Currency Credit Amount")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = true;
            }
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
                    }
                    field("Total Debe div.-adic."; TotalDebeACY)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = true;
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
                    }
                    field("Total haber div.-adic."; TotalHaberACY)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Visible = true;
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
                ToolTip = 'Registra el documento que originó esta previsualización.';

                trigger OnAction()
                var
                    PreviewContext: Codeunit "DIMA Preview Context";
                    Subscriber: Variant;
                    RecVar: Variant;
                    PreviewId: Guid;
                    RecRef: RecordRef;
                    CodeunitId: Integer;
                    SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
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

                    if Codeunit.Run(CodeunitId, RecVar) then
                        CurrPage.Close();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        CalculateTotals();
    end;

    var
        TotalDebeLCY: Decimal;
        TotalHaberLCY: Decimal;
        TotalDebeACY: Decimal;
        TotalHaberACY: Decimal;


    local procedure CalculateTotals()
    var
        GLEntry: Record "G/L Entry" temporary;
    begin
        TotalDebeLCY := 0;
        TotalHaberLCY := 0;
        TotalDebeACY := 0;
        TotalHaberACY := 0;

        GLEntry.Copy(Rec, true);

        if GLEntry.FindSet() then
            repeat
                TotalDebeLCY += GLEntry."Debit Amount";
                TotalHaberLCY += GLEntry."Credit Amount";
                TotalDebeACY += GLEntry."Add.-Currency Debit Amount";
                TotalHaberACY += GLEntry."Add.-Currency Credit Amount";
            until GLEntry.Next() = 0;
    end;

    local procedure GetPostingCodeunit(RecRef: RecordRef): Integer
    begin
        case RecRef.Number() of
            Database::"Sales Header":
                exit(Codeunit::"Sales-Post (Yes/No)");

            Database::"Purchase Header":
                exit(Codeunit::"Purch.-Post (Yes/No)");

            Database::"Gen. Journal Line",
            Database::"Item Journal Line":
                exit(Codeunit::"Gen. Jnl.-Post");

            Database::"FA Journal Line":
                exit(Codeunit::"FA. Jnl.-Post");
        end;

        exit(0);
    end;
}
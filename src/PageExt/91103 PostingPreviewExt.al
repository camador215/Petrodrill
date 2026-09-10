pageextension 91103 "DIMA G/L Posting Preview Ext" extends "G/L Posting Preview"
{
    layout
    {
        modify("Table Name")
        {
            trigger OnDrillDown()
            begin
                ShowEntries();
            end;
        }
        modify("No. of Records")
        {
            trigger OnDrillDown()
            begin
                ShowEntries();
            end;
        }
    }
    actions
    {
        modify(Show)
        {
            Visible = false;
        }
        addbefore(Show)
        {
            action(Show_DIMA)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Mostrar movimientos relacionados';
                Image = ViewDocumentLine;
                ToolTip = 'Ver detalles sobre otros movimientos relacionados con el registro de la contabilidad general.';

                trigger OnAction()
                begin
                    ShowEntries();
                end;
            }
        }
        addfirst(Promoted)
        {
            actionref(Show_DIMA_Promoted; Show_DIMA)
            {
            }
        }
    }
    local procedure ShowEntries()
    var
        DIMAPostingPreviewMgt: Codeunit "DIMA Posting Preview Mgt.";
        PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
        RecRef: RecordRef;
        GLEntry: Record "G/L Entry";
        TempGLEntry: Record "G/L Entry" temporary;
        PreviewContext: Codeunit "DIMA Preview Context";
    begin

        DIMAPostingPreviewMgt.GetPostingPreviewEventHandler(
                PostingPreviewEventHandler);

        if Rec."Table ID" = Database::"G/L Entry" then begin
            PostingPreviewEventHandler.GetEntries(
                Rec."Table ID",
                RecRef);

            if RecRef.FindSet() then
                repeat
                    RecRef.SetTable(GLEntry);

                    TempGLEntry := GLEntry;
                    TempGLEntry.Insert();
                until RecRef.Next() = 0;

            Page.RunModal(
                Page::"G/L Entries Preview",
                TempGLEntry);

            if PreviewContext.IsRegisterRequested() then
                CurrPage.Close();
        end else begin
            PostingPreviewEventHandler.ShowEntries(Rec."Table ID");
        end;
    end;
}
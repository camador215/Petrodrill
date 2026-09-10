codeunit 91104 "DIMA Posting Preview Mgt."
{
    SingleInstance = true;

    var
        PosPreviewEventHandler: Codeunit "Posting Preview Event Handler";

    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Gen. Jnl.-Post Preview",
        OnBeforeShowAllEntries,
        '',
        false,
        false)]
    local procedure OnBeforeShowAllEntries(
        var TempDocumentEntry: Record "Document Entry" temporary;
        var IsHandled: Boolean;
        var PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler")
    begin
        PosPreviewEventHandler := PostingPreviewEventHandler;
    end;

    procedure GetPostingPreviewEventHandler(
        var Result: Codeunit "Posting Preview Event Handler")
    begin
        Result := PosPreviewEventHandler;
    end;
}
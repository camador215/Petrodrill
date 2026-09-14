codeunit 91104 "DIMA Posting Preview Mgt."
{
    //Este codeunit permite recuperar el codeunit "Posting Preview Event Handler"
    //que contiene todas las entradas y registros para ver la vista previa.
    //Sin esto no es posible cerrar consecutivamente las paginas 122 y 115
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
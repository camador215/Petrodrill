codeunit 91102 "DIMA Sales Post Events"
{
    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Sales-Post (Yes/No)",
        'OnBeforeConfirmSalesPost',
        '',
        false,
        false)]
    local procedure OnBeforeConfirmSalesPost(
        var SalesHeader: Record "Sales Header";
        var HideDialog: Boolean;
        var IsHandled: Boolean;
        var DefaultOption: Integer;
        var PostAndSend: Boolean)
    begin
        if not IsDIMARegisterRequest() then
            exit;

        HideDialog := true;
    end;

    local procedure IsDIMARegisterRequest(): Boolean
    var
        PreviewContext: Codeunit "DIMA Preview Context";
    begin
        exit(PreviewContext.IsRegisterRequested());
    end;
}
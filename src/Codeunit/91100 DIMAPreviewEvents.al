codeunit 91100 "DIMA Preview Events"
{
    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Gen. Jnl.-Post Preview",
        OnBeforeRunPreview,
        '',
        false,
        false)]
    local procedure OnBeforeRunPreview(
        Subscriber: Variant;
        RecVar: Variant)
    var
        PreviewContext: Codeunit "DIMA Preview Context";
    begin
        PreviewContext.SetContext(
            Subscriber,
            RecVar);
    end;
}
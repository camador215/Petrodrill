codeunit 91100 "DIMA Preview Events"
{
    //Este evento se ejecuta cuando el usuario procesa la vista previa
    //de un documento como factura de venta, compra, diario general, etc.
    //Su única funcion es guardar el documento que se va a previsualizar.
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
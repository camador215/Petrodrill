codeunit 91101 "DIMA Preview Context"
{
    //Este codeunit sirve para guardar y retornar el documento que 
    //se está previsualizando.
    SingleInstance = true;

    var
        PreviewId: Guid;
        Subscriber: Variant;
        RecVar: Variant;
        RegisterRequested: Boolean;

    //Guarda el codeunit en NewSubscriber
    //Guarda el documento en NewRecVar
    //antes de continuar la previsualización.
    procedure SetContext(
        NewSubscriber: Variant;
        NewRecVar: Variant)
    begin
        PreviewId := CreateGuid();
        Subscriber := NewSubscriber;
        RecVar := NewRecVar;
        RegisterRequested := false;
    end;

    //Retorna el contexto almacenado por SetContext
    procedure GetContext(
        var OutSubscriber: Variant;
        var OutRecVar: Variant): Guid
    begin
        OutSubscriber := Subscriber;
        OutRecVar := RecVar;

        exit(PreviewId);
    end;

    //RegisterRequested es usada para consultar si las
    //page 122 y 115 deben cerrarse consecutivamente.
    //true = deben cerrarse consecutivamente.
    //false = deben cerrarse consecutivamente.
    procedure RequestRegister()
    begin
        RegisterRequested := true;
    end;

    procedure IsRegisterRequested(): Boolean
    begin
        exit(RegisterRequested);
    end;

    //ClearContext() se usa cuando se genera una nueva vista previa.
    procedure ClearContext()
    begin
        Clear(PreviewId);
        Clear(Subscriber);
        Clear(RecVar);
        RegisterRequested := false;
    end;

    //Se asigna un codigo único al contexto para no generar errores.
    procedure HasContext(): Boolean
    begin
        exit(not IsNullGuid(PreviewId));
    end;

    //Este evento permite saber si un usuario confirmó
    //registrar un diario general.
    //Es util para saber si las pages 122 y 115 deben cerrarse consecutivamente.
    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Gen. Jnl.-Post",
        OnCodeOnAfterGenJnlPostBatchRun,
        '',
        false,
        false)]
    local procedure OnCodeOnAfterGenJnlPostBatchRun(var GenJnlLine: Record "Gen. Journal Line")
    begin
        RequestRegister();
    end;

    //Este evento permite saber si un usuario confirmó
    //registrar una factura de compra.
    //Es util para saber si las pages 122 y 115 deben cerrarse consecutivamente.
    [EventSubscriber(ObjectType::Codeunit,
                     Codeunit::"Purch.-Post",
                     OnAfterPostPurchaseDoc,
                     '',
                     false,
                     false)]
    local procedure OnAfterPostPurchaseDoc(
        PurchaseHeader: Record "Purchase Header")
    begin
        RequestRegister();
    end;

    //Este evento permite saber si un usuario confirmó
    //registrar una factura de venta.
    //Es util para saber si las pages 122 y 115 deben cerrarse consecutivamente.
    [EventSubscriber(ObjectType::Codeunit,
                     Codeunit::"Sales-Post",
                     OnAfterPostSalesDoc,
                     '',
                     false,
                     false)]
    local procedure OnAfterPostSalesDoc(
        SalesHeader: Record "Sales Header")
    begin
        RequestRegister();
    end;
}
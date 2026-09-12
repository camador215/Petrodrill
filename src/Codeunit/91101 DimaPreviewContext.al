codeunit 91101 "DIMA Preview Context"
{
    SingleInstance = true;

    var
        PreviewId: Guid;
        Subscriber: Variant;
        RecVar: Variant;
        RegisterRequested: Boolean;

    procedure SetContext(
        NewSubscriber: Variant;
        NewRecVar: Variant)
    begin
        PreviewId := CreateGuid();
        Subscriber := NewSubscriber;
        RecVar := NewRecVar;
        RegisterRequested := false;
    end;

    procedure GetContext(
        var OutSubscriber: Variant;
        var OutRecVar: Variant): Guid
    begin
        OutSubscriber := Subscriber;
        OutRecVar := RecVar;

        exit(PreviewId);
    end;

    procedure RequestRegister()
    begin
        RegisterRequested := true;
    end;

    procedure IsRegisterRequested(): Boolean
    begin
        exit(RegisterRequested);
    end;

    procedure ClearContext()
    begin
        Clear(PreviewId);
        Clear(Subscriber);
        Clear(RecVar);
        RegisterRequested := false;
    end;

    procedure HasContext(): Boolean
    begin
        exit(not IsNullGuid(PreviewId));
    end;

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
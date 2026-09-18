codeunit 91103 "DIMA Imp. Asientos Contables"
{
    procedure ImprimirAsientoContable(RecRef: RecordRef)
    begin
        case RecRef.Number() of
            Database::"Item Journal Line":
                ImprimirItemJournalLine(RecRef);
        end;
    end;

    local procedure ImprimirItemJournalLine(RecRef: RecordRef)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        RecRef.SetTable(ItemJournalLine);

        case ItemJournalLine."Source Code" of
            'RECLAS.JNL':
                RegistrarDiarioReclasificacionProducto(ItemJournalLine);

            'DIAPRODS':
                RegistrarDiarioProducto(ItemJournalLine);
        end;
    end;

    local procedure RegistrarDiarioReclasificacionProducto(var Rec: Record "Item Journal Line")
    var
        reporte: Report DIMA_ComprContableDiarioProd;
        docNoImpresos: Record DIMA_DocContabilizadosImpresos;
        diarioProducto: Record "Item Journal Line";
        seccionLoteDiario: Record "Item Journal Batch";
        nroComrpTipoGlosa: Codeunit DIMA_JobNroTipoGlosaAsiento;
    begin
        diarioProducto := Rec;
        seccionLoteDiario.Reset();
        seccionLoteDiario.SetRange(Name, diarioProducto."Journal Batch Name");
        seccionLoteDiario.FindFirst();
        docNoImpresos.Reset();
        docNoImpresos.SetRange(Impreso, false);
        //docNoImpresos.SetRange(CodigoAuditoria, seccionLoteDiario."Reason Code");
        //docNoImpresos.SetRange(CodigoAuditoria, diarioProducto."Reason Code");
        //docNoImpresos.SetRange(CodigoOrigen, diarioProducto."Source Code");
        docNoImpresos.SetRange(NroDocumento, diarioProducto."Document No.");

        if docNoImpresos.FindSet() then begin
            nroComrpTipoGlosa.AsignarNumeroTipoComprobanteParaDocumento(diarioProducto."Document No.", diarioProducto."Document Date");
            reporte.ColocarNroDocumentoCodigoOrigenCodAuditoria(docNoImpresos.CodigoOrigen, docNoImpresos.CodigoAuditoria, false);
            reporte.UseRequestPage(false);
            reporte.Run();
            docNoImpresos.ModifyAll(Impreso, true);
        end;
    end;

    local procedure RegistrarDiarioProducto(var Rec: Record "Item Journal Line")
    var
        reporte: Report DIMA_ComprContableDiarioProd;
        docNoImpresos: Record DIMA_DocContabilizadosImpresos;
        diarioProducto: Record "Item Journal Line";
        seccionLoteDiario: Record "Item Journal Batch";

    begin

        diarioProducto := Rec;

        seccionLoteDiario.Reset();

        seccionLoteDiario.SetRange(Name, diarioProducto."Journal Batch Name");
        seccionLoteDiario.FindFirst();

        docNoImpresos.Reset();
        docNoImpresos.SetRange(Impreso, false);
        //docNoImpresos.SetRange(CodigoAuditoria, seccionLoteDiario."Reason Code");
        docNoImpresos.SetRange(CodigoAuditoria, diarioProducto."Reason Code");
        docNoImpresos.SetRange(CodigoOrigen, diarioProducto."Source Code");

        if docNoImpresos.FindSet() then begin

            reporte.ColocarNroDocumentoCodigoOrigenCodAuditoria(docNoImpresos.CodigoOrigen, docNoImpresos.CodigoAuditoria, false);

            reporte.UseRequestPage(false);

            reporte.Run();

            docNoImpresos.ModifyAll(Impreso, true);

        end;
    end;
}
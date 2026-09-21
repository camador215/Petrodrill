codeunit 91103 "DIMA Imp. Asientos Contables"
{
    Permissions = tabledata DIMA_DocContabilizadosImpresos = rimd, tabledata "G/L Entry" = rimd;
    procedure ImprimirAsientoContable(RecRef: RecordRef)
    begin
        case RecRef.Number() of
            Database::"Item Journal Line":
                ImprimirItemJournalLine(RecRef);
            Database::"Gen. Journal Line":
                ImprimirGenJournalLine(RecRef);
            Database::"Warehouse Receipt Line":
                ImprimirRecepcionAlmacen(RecRef);
            Database::"Sales Header":
                ImprimirVenta(RecRef);
            Database::"Purchase Header":
                ImprimirCompra(RecRef);
        end;
    end;

    local procedure ImprimirCompra(RecRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        RecRef.SetTable(PurchaseHeader);

        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Invoice:
                OnAfterActionEvent_FacturaCompra(PurchaseHeader);
            PurchaseHeader."Document Type"::"Credit Memo":
                OnAfterActionEvent_NotaCreditoCompra(PurchaseHeader);
            PurchaseHeader."Document Type"::"Return Order":
                PedidoDevolucionCompra_AfterPost(PurchaseHeader);
        end;
    end;

    local procedure ImprimirVenta(RecRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
    begin
        RecRef.SetTable(SalesHeader);

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                OnAfterActionEvent_FacturaVentaBC(SalesHeader);
            SalesHeader."Document Type"::"Credit Memo":
                OnAfterActionEvent_NotaCreditoVenta(SalesHeader);
        end;
    end;

    local procedure ImprimirRecepcionAlmacen(RecRef: RecordRef)
    var
        WarehouseReceiptLine: Record "Warehouse Receipt Line";
    begin
        RecRef.SetTable(WarehouseReceiptLine);

        OnAfterActionEvent_RecepcionAlmacen(WarehouseReceiptLine."No.");
    end;

    local procedure ImprimirItemJournalLine(RecRef: RecordRef)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        RecRef.SetTable(ItemJournalLine);

        case ItemJournalLine."Source Code" of
            'RECLASSJNL':
                RegistrarDiarioReclasificacionProducto(ItemJournalLine);

            'ITEMJNL':
                RegistrarDiarioProducto(ItemJournalLine);
        end;
    end;

    local procedure ImprimirGenJournalLine(RecRef: RecordRef)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        RecRef.SetTable(GenJournalLine);

        case GenJournalLine."Source Code" of
            'PAYMENTJNL':
                RegistroDiarioPago(GenJournalLine);
            'GENJNL':
                RegistroDiarioGeneral(GenJournalLine);
            'CASHRECJNL':
                RegistroDiarioRecepcionEfectivo(GenJournalLine);
            'PURCHJNL':
                OnAfterActionEvent_DiarioCompra(GenJournalLine);
        end;
    end;
    /******************************DIARIO RECLASIFICACION PRODUCTO***************************/
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
    /********************************************* DIARIO DE PRODUCTOS **************************************/
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

    /********************************************DIARIO DE PAGO*******************************************/
    local procedure RegistroDiarioPago(var Rec: Record "Gen. Journal Line")
    var
        reporte: Report DIMA_ComprContableDiarios;
        docNoImpresos: Record DIMA_DocContabilizadosImpresos;
        pago: Record "Gen. Journal Line";
    begin

        pago := Rec;

        docNoImpresos.Reset();
        docNoImpresos.SetRange(Impreso, false);
        docNoImpresos.SetRange(CodigoDiario, pago."Journal Batch Name");
        docNoImpresos.SetRange(CodigoOrigen, pago."Source Code");

        if docNoImpresos.FindSet() then begin

            reporte.ColocarNroDocumentoCodigoOrigenCodDiario(docNoImpresos.CodigoOrigen, docNoImpresos.CodigoDiario, false);

            reporte.UseRequestPage(false);

            reporte.Run();

            docNoImpresos.ModifyAll(Impreso, true);

        end;
    end;

    /**********************************DIARIO RECEPCION DE EFECTIVO******************************************/
    local procedure RegistroDiarioRecepcionEfectivo(var Rec: Record "Gen. Journal Line")
    var
        reporte: Report DIMA_ComprContableDiarios;
        docNoImpresos: Record DIMA_DocContabilizadosImpresos;
        recepEfectivo: Record "Gen. Journal Line";
        asientoContCU: Codeunit DIMA_JobNroTipoGlosaAsiento;
        cobroDeFactAdic: Boolean;
        movCliente: Record "Cust. Ledger Entry";
    begin

        if (Rec."Account Type" = Rec."Account Type"::"Bank Account") and (Rec."Bal. Account Type" = Rec."Bal. Account Type"::Customer) then
            Rec."Posting Group" := Rec.GrupoRegistro;

        recepEfectivo := Rec;

        cobroDeFactAdic := asientoContCU.CobroDeFacturaAdicional(recepEfectivo."Document No.");

        if (cobroDeFactAdic) then
            exit;

        docNoImpresos.Reset();
        docNoImpresos.SetRange(Impreso, false);
        docNoImpresos.SetRange(CodigoDiario, recepEfectivo."Journal Batch Name");
        docNoImpresos.SetRange(CodigoOrigen, recepEfectivo."Source Code");

        if docNoImpresos.FindSet() then begin

            reporte.ColocarNroDocumentoCodigoOrigenCodDiario(docNoImpresos.CodigoOrigen, docNoImpresos.CodigoDiario, false);

            reporte.UseRequestPage(false);

            reporte.Run();

            docNoImpresos.ModifyAll(Impreso, true);

        end;
    end;

    /***********************************************DIARIO GENERAL**********************************************/
    local procedure RegistroDiarioGeneral(var Rec: Record "Gen. Journal Line")
    var
        reporte: Report DIMA_ComprContableDiarios;
        docNoImpresos: Record DIMA_DocContabilizadosImpresos;
        diarioGral: Record "Gen. Journal Line";
    begin

        diarioGral := Rec;

        docNoImpresos.Reset();
        docNoImpresos.SetRange(Impreso, false);
        docNoImpresos.SetRange(CodigoDiario, diarioGral."Journal Batch Name");
        docNoImpresos.SetRange(CodigoOrigen, diarioGral."Source Code");

        if docNoImpresos.FindSet() then begin


            reporte.ColocarNroDocumentoCodigoOrigenCodDiario(docNoImpresos.CodigoOrigen, docNoImpresos.CodigoDiario, false);

            reporte.UseRequestPage(false);

            reporte.Run();

            docNoImpresos.ModifyAll(Impreso, true);


        end;
    end;
    /********************************************* REGISTRO FACTURA VENTA*************************************************/
    local procedure OnAfterActionEvent_FacturaVentaBC(var Rec: Record "Sales Header")
    var

        factura: Record "Sales Invoice Header";

        reporte: Report DIMA_ComprobanteContableTrx;
        request: Text;

        asiento: Record DIMA_NroComprGlosaAsiento;
        docDimaImpresos: Record DIMA_DocContabilizadosImpresos;

        nroComrpTipoGlosa: Codeunit DIMA_JobNroTipoGlosaAsiento;
        confVenta: Record "Sales & Receivables Setup";

    begin

        Commit();

        confVenta.Reset();
        confVenta.Get();

        factura.Reset();
        factura.SetRange("Pre-Assigned No.", rec."No.");

        if (factura.FindFirst()) then begin

            CorregirDatosContabilidadDeDocumento(factura."No.", factura."Posting Date", factura."Source Code", tipoDocumento::Invoice);

            nroComrpTipoGlosa.AsignarNumeroTipoComprobanteParaDocumento(factura."No.", factura."Document Date");

            asiento.Reset();
            asiento.SetRange(DIMA_NroDocumento, factura."No.");
            asiento.SetRange(CodigoOrigen, factura."Source Code");

            docDimaImpresos.Reset();
            docDimaImpresos.SetRange(NroDocumento, factura."No.");
            docDimaImpresos.SetRange(CodigoOrigen, factura."Source Code");
            docDimaImpresos.SetRange(Impreso, false);

            IF (asiento.FindFirst()) and docDimaImpresos.FindSet() then begin

                reporte.ProcesarNroGlosaTipoComprobante(true);

                reporte.ColocarNroDocumento(factura."No.");

                reporte.UseRequestPage(false);

                reporte.Run();

                docDimaImpresos.ModifyAll(Impreso, true);
            end;

        end;

    end;

    /*********************************************  REGISTRO DE FACTURA DE COMPRA   ********************************************************/
    local procedure OnAfterActionEvent_FacturaCompra(var Rec: Record "Purchase Header")
    var

        factura: Record "Purch. Inv. Header";

        reporte: Report DIMA_ComprobanteContableTrx;
        request: Text;

        asiento: Record DIMA_NroComprGlosaAsiento;

        docDimaImpresos: Record DIMA_DocContabilizadosImpresos;

    begin

        factura.Reset();
        factura.SetRange("Pre-Assigned No.", rec."No.");

        if (factura.FindFirst()) then begin

            CorregirDatosContabilidadDeDocumento(factura."No.", factura."Posting Date", factura."Source Code", tipoDocumento::Invoice);

            asiento.Reset();
            asiento.SetRange(DIMA_NroDocumento, factura."No.");
            asiento.SetRange(CodigoOrigen, factura."Source Code");

            docDimaImpresos.Reset();
            docDimaImpresos.SetRange(NroDocumento, factura."No.");
            docDimaImpresos.SetRange(CodigoOrigen, factura."Source Code");
            docDimaImpresos.SetRange(Impreso, false);

            IF (asiento.FindFirst()) and (docDimaImpresos.FindSet()) then begin

                Reporte.ProcesarNroGlosaTipoComprobante(true);

                reporte.ColocarNroDocumento(factura."No.");

                reporte.UseRequestPage(false);

                reporte.Run();

                docDimaImpresos.ModifyAll(Impreso, true);

            end;


        end;
    end;
    /************************************CANCELAR FACTURA DE COMPRA *****************************************/
    local procedure OnAfterActionEvent_CancelarFactCompra(var Rec: Record "Purch. Inv. Header")
    var

        notaCreditoReg: Record "Purch. Cr. Memo Hdr.";

        reporte: Report DIMA_ComprobanteContableTrx;
        request: Text;

        asiento: Record DIMA_NroComprGlosaAsiento;

        docDimaImpresos: Record DIMA_DocContabilizadosImpresos;

    begin

        notaCreditoReg.Reset();
        notaCreditoReg.SetRange("Applies-to Doc. No.", rec."No.");

        if (notaCreditoReg.FindFirst()) then begin

            CorregirDatosContabilidadDeDocumento(notaCreditoReg."No.", notaCreditoReg."Posting Date", notaCreditoReg."Source Code", tipoDocumento::"Credit Memo");

            asiento.Reset();
            asiento.SetRange(DIMA_NroDocumento, notaCreditoReg."No.");
            asiento.SetRange(CodigoOrigen, notaCreditoReg."Source Code");

            docDimaImpresos.Reset();
            docDimaImpresos.SetRange(NroDocumento, notaCreditoReg."No.");
            docDimaImpresos.SetRange(CodigoOrigen, notaCreditoReg."Source Code");
            docDimaImpresos.SetRange(Impreso, false);

            IF (asiento.FindFirst()) and (docDimaImpresos.FindSet()) then begin

                Reporte.ProcesarNroGlosaTipoComprobante(true);

                reporte.ColocarNroDocumento(notaCreditoReg."No.");

                reporte.UseRequestPage(false);

                reporte.Run();

                docDimaImpresos.ModifyAll(Impreso, true);
            end;


        end;
    end;
    /**************************************REGISTRAR NOTA DE CREDITO COMPRA **************************************/
    local procedure OnAfterActionEvent_NotaCreditoCompra(var Rec: Record "Purchase Header")
    var

        notaCreditoReg: Record "Purch. Cr. Memo Hdr.";

        reporte: Report DIMA_ComprobanteContableTrx;
        request: Text;

        asiento: Record DIMA_NroComprGlosaAsiento;

        docDimaImpresos: Record DIMA_DocContabilizadosImpresos;

        nroComrpTipoGlosa: Codeunit DIMA_JobNroTipoGlosaAsiento;
    begin

        notaCreditoReg.Reset();
        notaCreditoReg.SetRange("Pre-Assigned No.", rec."No.");

        if (notaCreditoReg.FindFirst()) then begin

            CorregirDatosContabilidadDeDocumento(notaCreditoReg."No.", notaCreditoReg."Posting Date", notaCreditoReg."Source Code", tipoDocumento::"Credit Memo");

            asiento.Reset();
            asiento.SetRange(DIMA_NroDocumento, notaCreditoReg."No.");
            asiento.SetRange(CodigoOrigen, notaCreditoReg."Source Code");

            docDimaImpresos.Reset();
            docDimaImpresos.SetRange(NroDocumento, notaCreditoReg."No.");
            docDimaImpresos.SetRange(CodigoOrigen, notaCreditoReg."Source Code");
            docDimaImpresos.SetRange(Impreso, false);

            IF (asiento.FindFirst()) and (docDimaImpresos.FindSet()) then begin

                Reporte.ProcesarNroGlosaTipoComprobante(true);

                reporte.ColocarNroDocumento(notaCreditoReg."No.");

                reporte.UseRequestPage(false);

                reporte.Run();

                docDimaImpresos.ModifyAll(Impreso, true);
            end;

        end;
    end;
    /************************************************ REGISTRO RECEPCION DE ALMACEN **************************************************/
    local procedure OnAfterActionEvent_RecepcionAlmacen(CodigoRecepcion: Code[20])
    var

        recepAlmacen: Record "Posted Whse. Receipt Header";

        asiento: Record DIMA_NroComprGlosaAsiento;

        movContab: Record "G/L Entry";

        docDimaImpresos: Record DIMA_DocContabilizadosImpresos;

        reporte: Report DIMA_ComprobanteContableTrx;

        request: Text;

        siglaSerie: code[50];

        nro: code[50];
        intNro: Integer;

        nroRecepAsiento: code[100];

        codOrigen: Code[20];

        Windows: Dialog;

    begin

        recepAlmacen.Reset();
        recepAlmacen.SetRange("Whse. Receipt No.", CodigoRecepcion);


        if (recepAlmacen.FindFirst()) then begin

            siglaSerie := Format(recepAlmacen."No.").Substring(1, Format(recepAlmacen."No.").IndexOf('-') - 1);  //Text.CopyStr(Format(recepAlmacen."No."), 1, 6);

            nro := Text.CopyStr(Format(recepAlmacen."No."), Format(recepAlmacen."No.").IndexOf('-') + 1);

            Evaluate(intNro, nro);

            nroRecepAsiento := siglaSerie + '*' + Format(intNro + 1);

            movContab.Reset();
            movContab.SetFilter(DIMA_NroDocumento, nroRecepAsiento);

            if (movContab.FindFirst()) then
                codOrigen := movContab."Source Code";

            asiento.Reset();
            asiento.SetFilter(DIMA_NroDocumento, nroRecepAsiento);
            asiento.SetRange(CodigoOrigen, codOrigen);

            docDimaImpresos.Reset();
            docDimaImpresos.SetFilter(NroDocumento, nroRecepAsiento);
            docDimaImpresos.SetRange(CodigoOrigen, codOrigen);
            docDimaImpresos.SetRange(Impreso, false);

            CorregirDatosContabilidadDeDocumento(recepAlmacen."No.", recepAlmacen."Posting Date", '', tipoDocumento::" ");

            IF (asiento.FindFirst()) and (docDimaImpresos.FindSet()) then begin

                Reporte.ProcesarNroGlosaTipoComprobante(true);

                reporte.ColocarNroDocumento(asiento.DIMA_NroDocumento);

                reporte.UseRequestPage(false);

                reporte.Run();

                docDimaImpresos.ModifyAll(Impreso, true);

            end;
        end;

    end;
    /****************************************** DIARIO DE COMPRAS*******************************************/
    local procedure OnAfterActionEvent_DiarioCompra(var Rec: Record "Gen. Journal Line")
    var
        reporte: Report DIMA_ComprContableDiarioCompra;
        docNoImpresos: Record DIMA_DocContabilizadosImpresos;
        diarioCompra: Record "Gen. Journal Line";

    begin

        diarioCompra := Rec;

        docNoImpresos.Reset();
        docNoImpresos.SetRange(Impreso, false);
        docNoImpresos.SetRange(CodigoDiario, diarioCompra."Journal Batch Name");
        docNoImpresos.SetRange(CodigoOrigen, diarioCompra."Source Code");


        if docNoImpresos.FindSet() then begin

            CorregirDatosContabilidadDeDocumento(diarioCompra."Document No.", diarioCompra."Posting Date", diarioCompra."Source Code", tipoDocumento::" ");

            docNoImpresos.ModifyAll(Impreso, true);

            reporte.ColocarNroDocumentoCodigoOrigenCodDiario(docNoImpresos.CodigoOrigen, docNoImpresos.CodigoDiario, false);

            reporte.UseRequestPage(false);

            reporte.Run();

        end;
    end;
    //---------------------------------------------------CANCELAR FACTURA DE VENTA----------------------------------------//
    local procedure OnAfterActionEvent_CancelarFactVentaDesdeFactura(var Rec: Record "Sales Invoice Header")
    var

        notaCreditoReg: Record "Sales Cr.Memo Header";

        reporte: Report DIMA_ComprobanteContableTrx;

        asiento: Record DIMA_NroComprGlosaAsiento;

        docDimaImpresos: Record DIMA_DocContabilizadosImpresos;

    begin

        if (Format(rec."No.").StartsWith('FACVTREG')) then
            exit;

        notaCreditoReg.Reset();
        notaCreditoReg.SetRange("Applies-to Doc. No.", rec."No.");

        if (notaCreditoReg.FindFirst()) then begin

            CorregirDatosContabilidadDeDocumento(notaCreditoReg."No.", notaCreditoReg."Posting Date", notaCreditoReg."Source Code", tipoDocumento::"Credit Memo");

            asiento.Reset();
            asiento.SetRange(DIMA_NroDocumento, notaCreditoReg."No.");
            asiento.SetRange(CodigoOrigen, notaCreditoReg."Source Code");

            docDimaImpresos.Reset();
            docDimaImpresos.SetRange(NroDocumento, notaCreditoReg."No.");
            docDimaImpresos.SetRange(CodigoOrigen, notaCreditoReg."Source Code");
            docDimaImpresos.SetRange(Impreso, false);

            IF (asiento.FindFirst()) and (docDimaImpresos.FindSet()) then begin

                Reporte.ProcesarNroGlosaTipoComprobante(true);

                docDimaImpresos.ModifyAll(Impreso, true);

                Commit();

                reporte.ColocarNroDocumento(notaCreditoReg."No.");

                reporte.UseRequestPage(false);

                reporte.Run();


            end;

        end;
    end;
    //----------------------------------------------------REGISTRAR NOTA DE CREDITO DE VENTA----------------------------------//
    local procedure OnAfterActionEvent_NotaCreditoVenta(var Rec: Record "Sales Header")
    var

        notaCreditoReg: Record "Sales Cr.Memo Header";

        reporte: Report DIMA_ComprobanteContableTrx;


        asiento: Record DIMA_NroComprGlosaAsiento;

        docDimaImpresos: Record DIMA_DocContabilizadosImpresos;

    begin

        notaCreditoReg.Reset();
        notaCreditoReg.SetRange("Pre-Assigned No.", rec."No.");

        if (notaCreditoReg.FindFirst()) then begin

            CorregirDatosContabilidadDeDocumento(notaCreditoReg."No.", notaCreditoReg."Posting Date", notaCreditoReg."Source Code", tipoDocumento::"Credit Memo");

            asiento.Reset();
            asiento.SetRange(DIMA_NroDocumento, notaCreditoReg."No.");
            asiento.SetRange(CodigoOrigen, notaCreditoReg."Source Code");

            docDimaImpresos.Reset();
            docDimaImpresos.SetRange(NroDocumento, notaCreditoReg."No.");
            docDimaImpresos.SetRange(CodigoOrigen, notaCreditoReg."Source Code");
            docDimaImpresos.SetRange(Impreso, false);

            IF (asiento.FindFirst()) and (docDimaImpresos.FindSet()) then begin

                reporte.ProcesarNroGlosaTipoComprobante(true);

                docDimaImpresos.ModifyAll(Impreso, true);

                Commit();

                reporte.ColocarNroDocumento(notaCreditoReg."No.");

                reporte.UseRequestPage(false);

                reporte.Run();


            end;

        end;
    end;

    /****************************PEDIDO DEVOLUCION COMPRA**************************************/
    local procedure PedidoDevolucionCompra_AfterPost(var Rec: Record "Purchase Header")
    var
        notaCreditoReg: Record "Purch. Cr. Memo Hdr.";
        reporte: Report DIMA_ComprobanteContableTrx;
        asiento: Record DIMA_NroComprGlosaAsiento;
        docDimaImpresos: Record DIMA_DocContabilizadosImpresos;
    begin

        notaCreditoReg.Reset();
        notaCreditoReg.SetRange("Return Order No.", rec."No.");

        if (notaCreditoReg.FindFirst()) then begin

            CorregirDatosContabilidadDeDocumento(notaCreditoReg."No.", notaCreditoReg."Posting Date", notaCreditoReg."Source Code", tipoDocumento::"Credit Memo");

            asiento.Reset();
            asiento.SetRange(DIMA_NroDocumento, notaCreditoReg."No.");
            asiento.SetRange(CodigoOrigen, notaCreditoReg."Source Code");

            docDimaImpresos.Reset();
            docDimaImpresos.SetRange(NroDocumento, notaCreditoReg."No.");
            docDimaImpresos.SetRange(CodigoOrigen, notaCreditoReg."Source Code");
            docDimaImpresos.SetRange(Impreso, false);

            IF (asiento.FindFirst()) and (docDimaImpresos.FindSet()) then begin

                Reporte.ProcesarNroGlosaTipoComprobante(true);

                reporte.ColocarNroDocumento(notaCreditoReg."No.");

                reporte.UseRequestPage(false);

                reporte.Run();

                docDimaImpresos.ModifyAll(Impreso, true);
            end;

        end;
    end;

    local procedure CorregirDatosContabilidadDeDocumento(pNroDocumento: code[50]; pFechaRegistro: date; pCodigoOrigenCorrecto: code[50]; pTipoDocumentoCorrecto: Enum Microsoft.Finance.GeneralLedger.Journal."Gen. Journal Document Type")
    var
        movContab: Record "G/L Entry";
        asientosContab: Record DIMA_NroComprGlosaAsiento;
        glosasAsientos: Record DIMA_GlosaAsiento;
    begin

        movContab.Reset();
        movContab.SetRange("Document No.", pNroDocumento);
        movContab.SetRange("Posting Date", pFechaRegistro);

        if (movContab.FindSet()) then begin
            movContab.ModifyAll("Source Code", pCodigoOrigenCorrecto);
            movContab.ModifyAll("Document Type", pTipoDocumentoCorrecto);

            Commit();
        end;


        asientosContab.Reset();
        asientosContab.SetRange(DIMA_NroDocumento, pNroDocumento);
        asientosContab.SetRange(FechaRegistro, pFechaRegistro);

        if (asientosContab.FindSet()) then begin
            asientosContab.ModifyAll(CodigoOrigen, pCodigoOrigenCorrecto);
            asientosContab.ModifyAll(TipoDocumento, pTipoDocumentoCorrecto);

            Commit();
        end;

    end;

    var
        tipoDocumento: enum Microsoft.Finance.GeneralLedger.Journal."Gen. Journal Document Type";
}
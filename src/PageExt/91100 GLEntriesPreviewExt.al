pageextension 91100 "DIMA G/L Entries Preview" extends "G/L Entries Preview"
{
    actions
    {
        addlast(Processing)
        {
            action(DIMARegister)
            {
                ApplicationArea = All;
                Caption = 'Registrar';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Registra el documento que originó esta previsualización.';

                trigger OnAction()
                var
                    PreviewContext: Codeunit "DIMA Preview Context";
                    Subscriber: Variant;
                    RecVar: Variant;
                    PreviewId: Guid;
                    SalesHeader: Record "Sales Header";
                    SalesPostYesNo: Codeunit "Sales-Post (Yes/No)";
                begin
                    PreviewId :=
                        PreviewContext.GetContext(
                            Subscriber,
                            RecVar);

                    if IsNullGuid(PreviewId) then
                        Error('No existe un contexto de Preview activo.');

                    SalesHeader.Copy(RecVar);

                    if SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice then
                        Error(
                            'El documento %1 no es una factura de venta.',
                            SalesHeader."No.");

                    // Ejecutar el mismo codeunit estándar utilizado por el botón Registrar/Post.
                    SalesPostYesNo.Run(SalesHeader);
                end;
            }
        }
    }
}
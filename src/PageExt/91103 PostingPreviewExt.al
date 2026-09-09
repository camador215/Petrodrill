pageextension 91103 "DIMA G/L Posting Preview Ext" extends "G/L Posting Preview"
{
    // layout
    // {
    //     modify("Table Name")
    //     {
    //         ApplicationArea = All;
    //         ToolTip = 'Specifies the table for which you want to preview the posting.';
    //         trigger OnDrillDown()
    //         begin
    //             PostingPreviewEventHandler.ShowEntries(Rec."Table ID");
    //             message('Drill down on Table Name field triggered. Table ID: %1', Rec."Table ID");
    //         end;
    //     }
    // }
    // var
    //     PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler";
}
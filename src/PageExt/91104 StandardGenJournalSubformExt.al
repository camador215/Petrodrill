pageextension 91104 "Standard Gen. Journal SF Ext" extends "Standard Gen. Journal Subform"
{
    layout
    {
        modify(Amount)
        {
            visible = false;
        }
        modify("Bal. VAT Amount")
        {
            visible = false;
        }
        modify("Bal. Account Type")
        {
            visible = false;
        }
        modify("Bal. Account No.")
        {
            visible = false;
        }
        modify("Bal. Gen. Posting Type")
        {
            visible = false;
        }
        modify("Bal. Gen. Bus. Posting Group")
        {
            visible = false;
        }
        modify("Bal. Gen. Prod. Posting Group")
        {
            visible = false;
        }

        modify("Debit Amount")
        {
            Visible = true;
        }

        modify("Credit Amount")
        {
            Visible = true;
        }


    }
}
page 50192 "Record Delete"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "Seperate Record Deletion Table";
    Editable = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field("Table ID"; rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; rec."Table Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Company; rec.Company)
                {
                    ApplicationArea = All;
                    Editable = false;  // visually read-only but still gets populated via OnNewRecord
                }
                field("Table Action"; Rec."Table Action")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No. of Records"; rec."No. of Records")
                {
                    ApplicationArea = All;
                    Editable = false;
                }


                field("No. of Table Relation Errors"; rec."No. of Table Relation Errors")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Delete Records"; rec."Delete Records")
                {
                    ApplicationArea = All;
                    Width = 7;
                }
                // field("Table Order"; Rec."Table Order")
                // {
                //     ApplicationArea = All;
                // }
                // field("Table Type"; Rec."Table Type")
                // {
                //     ApplicationArea = All;
                // }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Action1)
            {
                ApplicationArea = All;
                Caption = 'Insert/Update Tables';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Refresh;
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                    Rec_RecordDeletionTable: Record "Seperate Record Deletion Table";
                    Istream: InStream;
                    JSONTextline, JSONText, FileName, SheetName, FileExtension : Text;
                    ExcelBuffer: Record "Excel Buffer" temporary;
                    TotalCol: Integer;
                begin
                    if not UploadIntoStream('Select File to Import', '', 'All Supported Files (*.json;*.xlsx)|*.json;*.xlsx|JSON Files (*.json)|*.json|Excel Files (*.xlsx)|*.xlsx', FileName, Istream) then
                        Error(GetLastErrorText);


                    if FileName = '' then
                        exit;

                    // Determine file type by extension
                    FileExtension := LowerCase(CopyStr(FileName, StrLen(FileName) - 3, 4));

                    case FileExtension of
                        'json':
                            begin
                                while not Istream.EOS() do begin
                                    Istream.ReadText(JSONTextline);
                                    JSONText += JSONTextline;
                                end;

                                if JSONText = '' then
                                    Error('The uploaded JSON file is empty.');

                                RecordDletionMgmt.InsertFromJson(JSONText);
                                Message('Record inserted successfully from JSON.');
                            end;

                        'xlsx':
                            begin
                                SheetName := ExcelBuffer.SelectSheetsNameStream(Istream);

                                if SheetName = '' then
                                    Error('No sheet selected or file is invalid.');

                                ExcelBuffer.OpenBookStream(Istream, SheetName);
                                ExcelBuffer.ReadSheet();

                                // Read header row (Row 1) to get total columns
                                ExcelBuffer.SetRange("Row No.", 1);
                                TotalCol := ExcelBuffer.Count();

                                if TotalCol = 0 then
                                    Error('The Excel sheet appears to be empty.');

                                // Process data rows (Row 2 onwards)
                                ExcelBuffer.Reset();
                                ExcelBuffer.SetFilter("Row No.", '>1');

                                if ExcelBuffer.FindSet() then
                                    repeat
                                        // Map Excel cells to JSON and reuse the same codeunit
                                        // Assumes columns: 1=tableId, 2=company, 3=tableType, 4=tableAction, 5=tableOrder
                                        JSONText := BuildJsonFromExcelRow(ExcelBuffer, TotalCol);
                                        if JSONText <> '' then
                                            RecordDletionMgmt.InsertFromJson(JSONText);
                                    until ExcelBuffer.Next() = 0;

                                Message('Records inserted successfully from Excel.');
                            end;

                        else
                            Error('Unsupported file type: %1. Please upload a .json or .xlsx file.', FileName);
                    end;
                    Rec_RecordDeletionTable.Reset();
                    Rec_RecordDeletionTable.SetRange("No. of Records", 0);
                    Rec_RecordDeletionTable.SetRange("Table Action", rec."Table Action");
                    // Rec_RecordDeletionTable.SetRange("Table Order", rec."Table Order");
                    // Rec_RecordDeletionTable.SetRange("Table Type", rec."Table Type");
                    if Rec_RecordDeletionTable.FindSet() then
                        repeat
                            IF TryGetRecordCount(Rec_RecordDeletionTable."Table ID") then;
                        until Rec_RecordDeletionTable.Next() = 0;
                end;


            }
            action(Action2)
            {
                ApplicationArea = All;
                Caption = 'Export In JSON';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                Image = Refresh;
                trigger OnAction();
                var
                    Rec_RecordDeletionTable: Record "Seperate Record Deletion Table";
                    JsonArray: JsonArray;
                    JsonObj: JsonObject;
                    JsonText: Text;
                    TempBlob: Codeunit "Temp Blob";
                    OStream: OutStream;
                    IStream: InStream;
                    FileName: Text;
                begin
                    Rec_RecordDeletionTable.Reset();
                    Rec_RecordDeletionTable.SetRange("No. of Records", 0);
                    Rec_RecordDeletionTable.SetRange("Table Action", Rec."Table Action");
                    // Rec_RecordDeletionTable.SetRange("Table Order", Rec."Table Order");
                    // Rec_RecordDeletionTable.SetRange("Table Type", Rec."Table Type");

                    if not Rec_RecordDeletionTable.FindSet() then begin
                        Message('No records found matching.');
                        exit;
                    end;

                    // Build JSON array from filtered records
                    repeat
                        Clear(JsonObj);
                        JsonObj.Add('tableId', Rec_RecordDeletionTable."Table ID");
                        JsonObj.Add('company', Rec_RecordDeletionTable."Company");
                        // JsonObj.Add('tableType', Format(Rec_RecordDeletionTable."Table Type"));
                        JsonObj.Add('tableAction', Format(Rec_RecordDeletionTable."Table Action"));
                        // JsonObj.Add('tableOrder', Format(Rec_RecordDeletionTable."Table Order"));
                        JsonArray.Add(JsonObj);
                    until Rec_RecordDeletionTable.Next() = 0;

                    // Write array directly — matches import format [{ }, { }]
                    JsonArray.WriteTo(JsonText);

                    // Write to TempBlob stream
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    OStream.WriteText(JsonText);

                    // Download
                    TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
                    FileName := StrSubstNo('RecordDeletion_%1_%2.json',
                        // Format(Rec."Table Type"),
                        Format(Rec."Table Action"),
                        Format(Today(), 0, '<Year4><Month,2><Day,2>'));

                    DownloadFromStream(IStream, 'Export Records', '', 'JSON Files (*.json)|*.json', FileName);
                end;


            }
            action(Action3)
            {
                ApplicationArea = All;
                Image = ClearLog;
                Caption = 'Mark Records to Delete';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                begin
                    RecordDletionMgmt.SetrecordToDelete(Rec."Table Action");
                end;
            }

            action(Action4)
            {
                ApplicationArea = All;
                Image = ClearLog;
                Caption = 'Clear Records to Delete';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                begin
                    RecordDletionMgmt.ClearRecordsToDelete(Rec."Table Action");
                end;
            }
            action(Action5)
            {
                ApplicationArea = All;
                Image = Delete;
                Caption = 'Delete Records';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                begin
                    RecordDletionMgmt.DeleteRecordsWithParems(Rec."Table Action");
                end;
            }

        }
    }

    trigger OnOpenPage()

    begin
        CurrPage.Caption('Record Deletion Tool ' + Format(Rec."Table Action"));
    end;

    trigger OnAfterGetRecord()
    var
        Rec_RecordDeletionTable: Record "seperate Record Deletion Table";
    begin
        Rec_RecordDeletionTable.Reset();
        Rec_RecordDeletionTable.SetRange("No. of Records", 0);
        Rec_RecordDeletionTable.SetRange("Table Action", rec."Table Action");
        if Rec_RecordDeletionTable.FindSet() then
            repeat
                IF TryGetRecordCount(Rec_RecordDeletionTable."Table ID") then;
            until Rec_RecordDeletionTable.Next() = 0;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if rec.GetFilter(Company) <> '' then
            rec.Company := rec.GetFilter(Company)
        else
            if CompanyFilterReserv = '' then
                rec.Company := CompanyName()
            else
                rec.Company := CompanyFilterReserv;


        if rec.GetFilter("Table Action") <> '' then
            Evaluate(rec."Table Action", rec.GetFilter("Table Action"))
        else
            rec."Table Action" := TableActionFilter;

    end;

    trigger OnModifyRecord(): Boolean
    begin
        if rec.GetFilter(Company) <> '' then
            rec.Company := rec.GetFilter(Company)
        else
            if CompanyFilterReserv = '' then
                rec.Company := CompanyName()
            else
                rec.Company := CompanyFilterReserv;


        if rec.GetFilter("Table Action") <> '' then
            Evaluate(rec."Table Action", rec.GetFilter("Table Action"))
        else
            rec."Table Action" := TableActionFilter;
    end;

    [TryFunction]
    procedure TryGetRecordCount(TableId: Integer)
    var
        RecRef: RecordRef;
        Rec_RDT: Record "seperate Record Deletion Table";
    begin
        Clear(Rec_RDT);
        Clear(RecRef);
        Rec_RDT.Reset();
        Rec_RDT.SetRange("Table ID", TableId);
        If Rec_RDT.FindFirst() then begin
            RecRef.Open(Rec_RDT."Table ID", false, CompanyName());
            Rec_RDT."No. of Records" := RecRef.Count();
            Rec_RDT.Modify(true);
            RecRef.Close();
        end;
    end;

    local procedure GetExcelCellValue(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
    begin
        TempExcelBuffer.Copy(ExcelBuffer, true);
        TempExcelBuffer.SetRange("Row No.", RowNo);
        TempExcelBuffer.SetRange("Column No.", ColNo);

        if TempExcelBuffer.FindFirst() then
            exit(TempExcelBuffer."Cell Value as Text");

        exit('');
    end;

    local procedure BuildJsonFromExcelRow(var ExcelBuffer: Record "Excel Buffer" temporary; TotalCol: Integer): Text
    var
        JsonObj: JsonObject;
        RowNo: Integer;
        ColValue: Text;
        ResultJson: Text;
        Rec_RecordDeletionTable: Record "Seperate Record Deletion Table";
    begin
        RowNo := ExcelBuffer."Row No.";

        // Column 1 → tableId
        ColValue := GetExcelCellValue(ExcelBuffer, RowNo, 1);
        if ColValue = '' then
            exit('');  // Skip empty rows
        JsonObj.Add('tableId', ColValue);

        // Column 2 → company
        JsonObj.Add('company', GetExcelCellValue(ExcelBuffer, RowNo, 2));

        // Column 3 → tableType
        JsonObj.Add('tableType', GetExcelCellValue(ExcelBuffer, RowNo, 3));

        // Column 4 → tableAction
        JsonObj.Add('tableAction', GetExcelCellValue(ExcelBuffer, RowNo, 4));

        // Column 5 → tableOrder
        JsonObj.Add('tableOrder', GetExcelCellValue(ExcelBuffer, RowNo, 5));

        JsonObj.WriteTo(ResultJson);
        exit(ResultJson);
    end;

    procedure UpdateFilters(Company: Text[250];
        TableAction: Enum "Table Actions")
    begin
        CompanyFilterReserv := Company;
        TableActionFilter := TableAction;
    end;

    var
        CompanyFilterReserv: Code[30];
        TableActionFilter: Enum "Table Actions";
}
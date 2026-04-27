page 50190 "Record Deletion Table"
{
    PageType = List;
    UsageCategory = None;
    ApplicationArea = All;
    SourceTable = "Record Deletion Table";
    Caption = 'Record Deletion Tool';
    // Permissions = TableData "17" = IMD, Tabledata "36" = IMD, Tabledata "37" = IMD, Tabledata "38" = IMD, Tabledata "39" = IMD, Tabledata "81" = IMD, Tabledata "21" = IMD, Tabledata "25" = IMD, Tabledata "32" = IMD, Tabledata "110" = IMD, TableData "111" = IMD, TableData "112" = IMD, TableData "113" = IMD, TableData "114" = IMD, TableData "115" = IMD, TableData "120" = IMD, Tabledata "121" = IMD, Tabledata "122" = IMD, Tabledata "123" = IMD, Tabledata "124" = IMD, Tabledata "125" = IMD, Tabledata "169" = IMD, Tabledata "379" = IMD, Tabledata "380" = IMD, Tabledata "271" = IMD, Tabledata "5802" = IMD, tabledata "6650" = IMD, tabledata "6660" = IMD;
    Permissions = TableData 17 = IMD, Tabledata 36 = IMD, Tabledata 37 = IMD, Tabledata 38 = IMD, Tabledata 39 = IMD, Tabledata 81 = IMD, Tabledata 21 = IMD, Tabledata 25 = IMD, Tabledata 32 = IMD, Tabledata 110 = IMD, TableData 111 = IMD, TableData 112 = IMD, TableData 113 = IMD, TableData 114 = IMD, TableData 115 = IMD, TableData 120 = IMD, Tabledata 121 = IMD, Tabledata 122 = IMD, Tabledata 123 = IMD, Tabledata 124 = IMD, Tabledata 125 = IMD, Tabledata 169 = IMD, Tabledata 379 = IMD, Tabledata 380 = IMD, Tabledata 271 = IMD, Tabledata 5802 = IMD, tabledata 6650 = IMD, tabledata 6660 = IMD;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Delete Records"; rec."Delete Records")
                {
                    ApplicationArea = All;
                    Width = 7;
                }
                field("Table ID"; rec."Table ID")
                {
                    ApplicationArea = All;
                    Width = 7;
                }
                field("Table Name"; rec."Table Name")
                {
                    ApplicationArea = All;
                    Width = 30;
                }
                field("No. of Records"; rec."No. of Records")
                {
                    ApplicationArea = All;
                }
                field("No. of Table Relation Errors"; rec."No. of Table Relation Errors")
                {
                    ApplicationArea = All;
                }
                field(Company; rec.Company)
                {
                    ApplicationArea = All;
                }

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
                Image = Refresh;
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                    Rec_RecordDeletionTable: Record "Record Deletion Table";
                begin
                    RecordDletionMgmt.InsertUpdateTables;
                    Rec_RecordDeletionTable.Reset();
                    if Rec_RecordDeletionTable.FindSet() then
                        repeat
                            IF TryGetRecordCount(Rec_RecordDeletionTable."Table ID") then;
                        until Rec_RecordDeletionTable.Next() = 0;
                end;
            }
            action(Action2)
            {
                ApplicationArea = All;
                Caption = 'Suggest Records to Delete';
                Image = Suggest;
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                begin
                    RecordDletionMgmt.SuggestRecordsToDelete;
                end;
            }
            action(Action3)
            {
                ApplicationArea = All;
                Image = ClearLog;
                Caption = 'Clear Records to Delete';
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                begin
                    RecordDletionMgmt.ClearRecordsToDelete;
                end;
            }
            action(Action4)
            {
                ApplicationArea = All;
                Image = Delete;
                Caption = 'Delete Records';
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                begin
                    RecordDletionMgmt.DeleteRecords();
                end;
            }
            action(Action5)
            {
                ApplicationArea = All;
                Image = Relationship;
                Caption = 'Check Table Relations';
                Visible = false;
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                begin
                    RecordDletionMgmt.CheckTableRelations();
                end;
            }
            action(Action6)
            {
                ApplicationArea = All;
                Image = Table;
                Caption = 'View Records';
                Visible = false;
                trigger OnAction();
                var
                    RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
                begin
                    RecordDletionMgmt.ViewRecords(Rec);
                end;
            }
            action(Action7)
            {
                Image = Select;
                Caption = 'Deleted selective Records';
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    ReportDataDeletionTool: Report DataDeletionTool;
                begin
                    ReportDataDeletionTool.GetTableNo(Rec."Table ID");
                    ReportDataDeletionTool.Run();
                end;
            }

            action(Action8)
            {
                Image = Select;
                Caption = 'Open Selective Records';
                ApplicationArea = All;
                Visible = false;
                trigger OnAction()
                var
                    Rec_RecordDeletionTable: Record "Seperate Record Deletion Table";
                    FilterPageBuilder: FilterPageBuilder;
                    RecordDeletionPage: Page "Record Delete";
                    ViewFilter: Text;
                    Caps: Text;
                begin
                    // Add the table to filter page with same caption as action
                    FilterPageBuilder.AddTable('Delete Selective Records From Tables', Database::"Seperate Record Deletion Table");

                    // Add enum fields as filter fields
                    FilterPageBuilder.AddFieldNo('Delete Selective Records From Tables', Rec_RecordDeletionTable.FieldNo("Table Action"));

                    // Open the filter dialog — exit only on Cancel
                    if not FilterPageBuilder.RunModal() then
                        exit;

                    // Get the view from filter builder
                    ViewFilter := FilterPageBuilder.GetView('Delete Selective Records From Tables');

                    Rec_RecordDeletionTable.Reset();

                    // FilterGroup(1) — locks filters, user can see but cannot change or remove them
                    if ViewFilter <> '' then begin
                        Rec_RecordDeletionTable.FilterGroup(1);
                        Rec_RecordDeletionTable.SetView(ViewFilter);
                        Rec_RecordDeletionTable.FilterGroup(0);  // Return to group 0 for any additional filters
                    end;

                    // Run the page with locked filters applied
                    RecordDeletionPage.SetTableView(Rec_RecordDeletionTable);
                    RecordDeletionPage.Run();
                end;
            }
            action(Action9)
            {
                ApplicationArea = All;
                Caption = 'Import Selective record';
                Image = Refresh;
                Visible = false;
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
                    if Rec_RecordDeletionTable.FindSet() then
                        repeat
                            IF TryGetRecordCount(Rec_RecordDeletionTable."Table ID") then;
                        until Rec_RecordDeletionTable.Next() = 0;
                end;


            }
            action(Action10)
            {
                ApplicationArea = All;
                Caption = 'Export In JSON';
                Image = Refresh;
                Visible = false;
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
                    if not Rec_RecordDeletionTable.FindSet() then begin
                        Message('No records found matching.');
                        exit;
                    end;

                    // Build JSON array from filtered records
                    repeat
                        Clear(JsonObj);
                        JsonObj.Add('tableId', Rec_RecordDeletionTable."Table ID");
                        JsonObj.Add('company', Rec_RecordDeletionTable."Company");
                        JsonObj.Add('tableAction', Format(Rec_RecordDeletionTable."Table Action"));
                        JsonArray.Add(JsonObj);
                    until Rec_RecordDeletionTable.Next() = 0;

                    // Write array directly — matches import format [{ }, { }]
                    JsonArray.WriteTo(JsonText);

                    // Write to TempBlob stream
                    TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
                    OStream.WriteText(JsonText);

                    // Download
                    TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
                    FileName := StrSubstNo('RecordDeletion_%1_%2_%3.json',
                        Format('ALL Type_'),
                        Format('ALL Actions_'),
                        Format(Today(), 0, '<Year4><Month,2><Day,2>'));

                    DownloadFromStream(IStream, 'Export Records', '', 'JSON Files (*.json)|*.json', FileName);
                end;


            }

        }
        area(Promoted)
        {
            actionref(Actionref_1; Action1) { }
            actionref(Actionref_2; Action2) { }
            actionref(Actionref_3; Action3) { }
            actionref(Actionref_4; Action4) { }
            actionref(Actionref_5; Action5) { }
            actionref(Actionref_6; Action6) { }
            actionref(Actionref_7; Action7) { }
            group("Data Delete Controller")
            {

                actionref(Actionref_8; Action8) { }
                actionref(Actionref_9; Action9) { }
                actionref(Actionref_10; Action10) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        Rec_RecordDeletionTable: Record "Record Deletion Table";
    begin
        Rec_RecordDeletionTable.Reset();
        Rec_RecordDeletionTable.SetRange("No. of Records", 0);
        if Rec_RecordDeletionTable.FindSet() then
            repeat
                IF TryGetRecordCount(Rec_RecordDeletionTable."Table ID") then;
            until Rec_RecordDeletionTable.Next() = 0;
    end;

    [TryFunction]
    procedure TryGetRecordCount(TableId: Integer)
    var
        RecRef: RecordRef;
        Rec_RDT: Record "Record Deletion Table";
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
}
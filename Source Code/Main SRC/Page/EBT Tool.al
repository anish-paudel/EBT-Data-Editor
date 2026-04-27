page 60100 "EBT Tool"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'EBT Tool';
    layout
    {
        area(Content)
        {
            // ── General ────────────────────────────────────────────
            group(General)
            {
                Caption = 'General';

                field(CompanyName; SelectedCompany)
                {
                    ApplicationArea = All;
                    Caption = 'Company Filter';
                    TableRelation = Company.Name;
                    ToolTip = 'Filter all cleanup views to a specific company.';
                }
            }

            // ── Data Editor ────────────────────────────────────────
            group(DataEditor)
            {
                Caption = 'Data Editor';

                field(DataEditorLink; DataEditorLbl)
                {
                    ApplicationArea = All;
                    Caption = 'Open Data Editor';
                    Style = StandardAccent;
                    Editable = false;
                    ToolTip = 'Open the data editor tool.';

                    trigger OnDrillDown()
                    begin
                        page.RunModal(Page::"Data Editor")
                    end;
                }
            }

            // ── Record Deletion ────────────────────────────────────
            group(RecordDeletion)
            {
                Caption = 'Record Deletion';

                field(RecordDeletionLink; RecordDeletionLbl)
                {
                    ApplicationArea = All;
                    Caption = 'Open Deletion Tool';
                    Style = StandardAccent;
                    Editable = false;
                    ToolTip = 'Open the record deletion tool.';
                    trigger OnDrillDown()
                    begin
                        page.RunModal(Page::"Record Deletion Table")
                    end;
                }
            }
            // ── Data Cleanup ───────────────────────────────────────
            // ── Data Cleanup ───────────────────────────────────────
            group(DataCleanup)
            {
                Caption = 'Data Cleanup';

                // ── Import / Export — top full section ─────────────
                label("Import / Export") { Style = Strong; }

                Fixed(ImportExportFixed)
                {
                    group(ImportGroup)
                    {
                        Caption = 'Import';
                        ShowCaption = false;

                        field(ImportSelectiveRecord; ImportSelectiveLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Ambiguous;
                            Editable = false;
                            ToolTip = 'Click to Import cleanup records from a JSON or Excel file.';
                            trigger OnDrillDown()
                            begin
                                RunImport();
                            end;
                        }
                    }

                    group(ExportGroup)
                    {
                        Caption = 'Export';
                        ShowCaption = false;

                        field(ExportInJSON; ExportInJSONLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = Ambiguous;
                            Editable = false;
                            ToolTip = 'Click to Export all cleanup records to a JSON file.';
                            trigger OnDrillDown()
                            begin
                                RunExport();
                            end;
                        }
                    }
                }
                label("Data Cleanup Tools") { Style = Strong; }

                Fixed(tools)
                {
                    group("Custom Tables")
                    {

                        field(Custom; CustomLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = StandardAccent;
                            Editable = false;
                            ToolTip = 'Open Custom table cleanup view.';
                            trigger OnDrillDown()
                            begin
                                OpenCleanupPage("Table Actions"::"Custom");
                            end;
                        }
                    }
                    group(BCCleanup)
                    {
                        Caption = 'Business Central';

                        field(BCSetups; BCSetupsLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = StandardAccent;
                            Editable = false;
                            ToolTip = 'Open BC Setups cleanup view.';
                            trigger OnDrillDown()
                            begin
                                OpenCleanupPage("Table Actions"::"BC-Setups");
                            end;
                        }
                        field(BCMasters; BCMastersLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = StandardAccent;
                            Editable = false;
                            ToolTip = 'Open BC Masters cleanup view.';
                            trigger OnDrillDown()
                            begin
                                OpenCleanupPage("Table Actions"::"BC-Masters");
                            end;
                        }
                        field(BCTransaction; BCTransactionLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = StandardAccent;
                            Editable = false;
                            ToolTip = 'Open BC Transactions cleanup view.';
                            trigger OnDrillDown()
                            begin
                                OpenCleanupPage("Table Actions"::"BC-Transactions");
                            end;
                        }

                    }

                    group(LSCleanup)
                    {
                        Caption = 'LS Central';

                        field(LSSetups; LSSetupsLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = StandardAccent;
                            Editable = false;
                            ToolTip = 'Open LS Setups cleanup view.';
                            trigger OnDrillDown()
                            begin
                                OpenCleanupPage("Table Actions"::"LS-Setups");
                            end;
                        }
                        field(LSMasters; LSMastersLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = StandardAccent;
                            Editable = false;
                            ToolTip = 'Open LS Masters cleanup view.';
                            trigger OnDrillDown()
                            begin
                                OpenCleanupPage("Table Actions"::"LS-Masters");
                            end;
                        }
                        field(LSTransaction; LSTransactionLbl)
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            Style = StandardAccent;
                            Editable = false;
                            ToolTip = 'Open LS Transactions cleanup view.';
                            trigger OnDrillDown()
                            begin
                                OpenCleanupPage("Table Actions"::"LS-Transactions");
                            end;
                        }

                    }
                }
            }
        }

    }


    trigger OnInit()
    begin
        AuthenticateUser();
    end;

    // ── Variables ──────────────────────────────────────────────────
    var
        SelectedCompany: Text[250];

        // Labels — Data Editor & Record Deletion
        DataEditorLbl: Label 'Data Editor Tool';
        RecordDeletionLbl: Label 'Record Deletion Tool';

        // Labels — Import / Export
        ImportSelectiveLbl: Label 'Import Selective Record (JSON / Excel)';
        ExportInJSONLbl: Label 'Export All Records (JSON)';

        // Labels — BC Cleanup
        BCSetupsLbl: Label 'Setups (BCS)';
        BCMastersLbl: Label 'Masters (BCM)';
        BCTransactionLbl: Label 'Transaction (BCT)';
        BCCustomLbl: Label 'Custom (BCC)';

        // Labels — LS Cleanup
        LSSetupsLbl: Label 'Setups (LSS)';
        LSMastersLbl: Label 'Masters (LSM)';
        LSTransactionLbl: Label 'Transaction (LST)';
        LSCustomLbl: Label 'Custom (CST)';
        CustomLbl: Label 'Custom (CST)';

    // ── Authentication ─────────────────────────────────────────────
    local procedure AuthenticateUser()
    var
        EBTPasswordPage: Page "EBT Password Input";
        FixedPassword: Label 'Admin@123', Locked = true;
    begin
        EBTPasswordPage.LookupMode(true);
        if EBTPasswordPage.RunModal() <> Action::LookupOK then
            Error('');

        if EBTPasswordPage.GetPassword() <> FixedPassword then
            Error('Access Denied. Incorrect password.');
    end;

    // ── Shared Cleanup Page Opener ─────────────────────────────────
    local procedure OpenCleanupPage(TableAction: Enum "Table Actions")
    var
        RecordDeletionPage: Page "Record Delete";
        Rec_RecordDeletionTable: Record "Seperate Record Deletion Table";
    begin
        Rec_RecordDeletionTable.Reset();
        Rec_RecordDeletionTable.FilterGroup(1);
        Rec_RecordDeletionTable.SetRange("Table Action", TableAction);
        if SelectedCompany <> '' then
            Rec_RecordDeletionTable.SetRange(Company, SelectedCompany);
        Rec_RecordDeletionTable.FilterGroup(0);
        RecordDeletionPage.SetTableView(Rec_RecordDeletionTable);
        RecordDeletionPage.UpdateFilters(SelectedCompany, TableAction);
        RecordDeletionPage.Run();
    end;

    // ── Import ─────────────────────────────────────────────────────
    local procedure RunImport()
    var
        RecordDletionMgmt: Codeunit "Record Deletion Mgmt";
        Rec_RecordDeletionTable: Record "Seperate Record Deletion Table";
        Istream: InStream;
        JSONTextline, JSONText, FileName, SheetName, FileExtension : Text;
        ExcelBuffer: Record "Excel Buffer" temporary;
        TotalCol: Integer;
    begin
        if not UploadIntoStream(
            'Select File to Import', '',
            'All Supported Files (*.json;*.xlsx)|*.json;*.xlsx|JSON Files (*.json)|*.json|Excel Files (*.xlsx)|*.xlsx',
            FileName, Istream)
        then
            exit;

        if FileName = '' then
            exit;

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
                    Message('Records inserted successfully from JSON.');
                end;

            'xlsx':
                begin
                    SheetName := ExcelBuffer.SelectSheetsNameStream(Istream);

                    if SheetName = '' then
                        Error('No sheet selected or file is invalid.');

                    ExcelBuffer.OpenBookStream(Istream, SheetName);
                    ExcelBuffer.ReadSheet();

                    ExcelBuffer.SetRange("Row No.", 1);
                    TotalCol := ExcelBuffer.Count();

                    if TotalCol = 0 then
                        Error('The Excel sheet appears to be empty.');

                    ExcelBuffer.Reset();
                    ExcelBuffer.SetFilter("Row No.", '>1');

                    if ExcelBuffer.FindSet() then
                        repeat
                            JSONText := BuildJsonFromExcelRow(ExcelBuffer, TotalCol);
                            if JSONText <> '' then
                                RecordDletionMgmt.InsertFromJson(JSONText);
                        until ExcelBuffer.Next() = 0;

                    Message('Records inserted successfully from Excel.');
                end;

            else
                Error('Unsupported file type: %1. Please upload a .json or .xlsx file.', FileName);
        end;

        // Refresh record counts for any rows that show 0
        Rec_RecordDeletionTable.Reset();
        Rec_RecordDeletionTable.SetRange("No. of Records", 0);
        if Rec_RecordDeletionTable.FindSet() then
            repeat
                if TryGetRecordCount(Rec_RecordDeletionTable."Table ID") then;
            until Rec_RecordDeletionTable.Next() = 0;
    end;

    // ── Export ─────────────────────────────────────────────────────
    local procedure RunExport()
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
        if SelectedCompany <> '' then
            Rec_RecordDeletionTable.SetRange(Company, SelectedCompany);

        Rec_RecordDeletionTable.SetCurrentKey("Table Action");

        if Rec_RecordDeletionTable.FindSet() then begin
            repeat
                Clear(JsonObj);
                JsonObj.Add('tableId', Rec_RecordDeletionTable."Table ID");
                JsonObj.Add('company', Rec_RecordDeletionTable.Company);
                JsonObj.Add('tableAction', Format(Rec_RecordDeletionTable."Table Action"));
                JsonArray.Add(JsonObj);
            until Rec_RecordDeletionTable.Next() = 0;
        end else begin
            Message('No records found to export.');
            exit;
        end;

        JsonArray.WriteTo(JsonText);
        TempBlob.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(JsonText);
        TempBlob.CreateInStream(IStream, TextEncoding::UTF8);
        FileName := StrSubstNo('RecordDeletion_ALL_%1.json',
            Format(Today(), 0, '<Year4><Month,2><Day,2>'));

        DownloadFromStream(IStream, 'Export Records', '', 'JSON Files (*.json)|*.json', FileName);
    end;
    // ── Record Count Helper ────────────────────────────────────────
    [TryFunction]
    procedure TryGetRecordCount(TableId: Integer)
    var
        RecRef: RecordRef;
        Rec_RDT: Record "Record Deletion Table";
    begin
        Rec_RDT.Reset();
        Rec_RDT.SetRange("Table ID", TableId);
        if Rec_RDT.FindFirst() then begin
            RecRef.Open(Rec_RDT."Table ID", false, CompanyName());
            Rec_RDT."No. of Records" := RecRef.Count();
            Rec_RDT.Modify(true);
            RecRef.Close();
        end;
    end;

    // ── Excel Helpers ──────────────────────────────────────────────
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
        ResultJson: Text;
    begin
        RowNo := ExcelBuffer."Row No.";

        if GetExcelCellValue(ExcelBuffer, RowNo, 1) = '' then
            exit('');  // Skip empty rows

        JsonObj.Add('tableId', GetExcelCellValue(ExcelBuffer, RowNo, 1));
        JsonObj.Add('company', GetExcelCellValue(ExcelBuffer, RowNo, 2));
        JsonObj.Add('tableAction', GetExcelCellValue(ExcelBuffer, RowNo, 3));

        JsonObj.WriteTo(ResultJson);
        exit(ResultJson);
    end;
}
page 60101 "EBT Password Input"
{
    PageType = StandardDialog;
    Caption = 'EBT Tool - Admin Login';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(Login)
            {
                Caption = 'Authentication Required';

                field(Password; EnteredPassword)
                {
                    ApplicationArea = All;
                    Caption = 'Admin Password';
                    ExtendedDatatype = Masked;  // This masks the input like a password field
                }
            }
        }
    }

    var
        EnteredPassword: Text;


    procedure GetPassword(): Text
    begin
        exit(EnteredPassword);
    end;
}
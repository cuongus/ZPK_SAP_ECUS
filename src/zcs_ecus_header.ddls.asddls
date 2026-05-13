@EndUserText.label: 'Custom CDS for ECUS Header'
@ObjectModel: {
    query: {
            implementedBy: 'ABAP:ZCL_APP_ECUS_DATA'
            }
    }
@Metadata.allowExtensions: true
@Search.searchable: true
define root custom entity zcs_ecus_header
  // with parameters parameter_name : parameter_type
{
      @Search.defaultSearchElement   : true
      @Consumption.valueHelpDefinition:[
      { entity               : { name: 'I_BillingDocument', element: 'BillingDocument' }
      }]
  key BillingDocument        : zde_vbeln_vf;  //Pro-Forma Invoice
      DeclarationNo          : abap.char(12); //Số tờ khai Hải quan
      BillingDocumentDate    : abap.datn;     //Invoice Date
      ShipperExporterName    : abap.char(255);
      ShipperExporterAddress : abap.char(255);
      BuyerImporterName      : abap.char(255);
      BuyerImporterAddress   : abap.char(255);
      ConsigneeName          : abap.char(255);
      ConsigneeAddress       : abap.char(255);
      NotifyParty1           : abap.char(255);
      NotifyParty2           : abap.char(255);
      Shipto                 : abap.char(255);
      TheThirtParty          : abap.char(255);
      Remarks                : abap.char(255);
      Incoterms              : abap.char(255);
      PortofShipment         : abap.char(255);
      portofshipment2        : abap.char(255);
      PortofDischarge        : abap.char(255);
      FinalDestination       : abap.char(255);
      VesselsNames           : abap.char(255);
      SaillingOnOrAbout      : abap.datn;
      TrunkVessel            : abap.char(255);
      EstimatedOfDelivery    : abap.datn;
      CountryOfOrigin        : abap.char(100);
      BillOfLading           : abap.char(255);
      Carrier                : abap.char(255);
      TermofPayment          : abap.char(255);
      TermsOfDelivery        : abap.char(255);
      DepositContract        : abap.char(255);
      CYLINDERQuantity       : abap.dec( 18, 3 );
      CYLINDERAmount         : abap.dec( 24, 3 );
      TermOfPaymentContract  : abap.char(255);
      TimeOfDelivery         : abap.datn;
      PartialShipment        : abap.char(255);
      SalesOrganization      : abap.char(10);
      DistributionChannel    : abap.char(10);
      SearchTerm1            : abap.char(255);
      CommercialInvoice      : abap.char(255);
      ShipperVGM             : abap.char(255);
      AddressVGM             : abap.char(255);
      soLC                   : abap.char(255);
      ngayMoLC               : abap.char(255);
      Criticality            : abap.char(1);
      StatusOfDeclaration    : abap.char(10); //Trang thái tờ khai
      StatusOfIntegration    : abap.char(10); //Trạng thái tích hợp
      Message                : abap.char(255);

      @Semantics.largeObject : { mimeType: 'Mimetype',
      //                      fileName: 'Filename',
                      contentDispositionPreference: #INLINE }
      FilePackingListHQ      : zde_attachment;
      @Semantics.mimeType    : true
      Mimetype               : zde_mime_type;

      /* --Association-- */
      _ECUSItems             : composition [0..*] of zcs_ecus_items;
}
